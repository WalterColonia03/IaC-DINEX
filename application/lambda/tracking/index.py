"""
Lambda Handler - Sistema de Tracking DINEX
Maneja consultas y actualizaciones de tracking de paquetes
"""

import json
import boto3
import os
from datetime import datetime
import uuid
from decimal import Decimal

# Inicialización de clientes AWS (se reutilizan en warm starts)
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

# Variables de entorno
TABLE_NAME = os.environ.get('TABLE_NAME')
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'dev')
SNS_TOPIC = os.environ.get('SNS_TOPIC')

table = dynamodb.Table(TABLE_NAME)


class DecimalEncoder(json.JSONEncoder):
    """Convierte Decimal de DynamoDB a float para serialización JSON"""
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)


def handler(event, context):
    """
    Handler principal invocado por API Gateway

    Routes:
    - GET /health: Health check
    - GET /tracking?tracking_id=X: Consultar tracking
    - POST /tracking: Actualizar ubicación
    """
    print(f"Event: {json.dumps(event)}")

    # TODO: Implementar autenticación con API Keys
    # TODO: Agregar rate limiting por IP

    try:
        http_method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')
        path = event.get('requestContext', {}).get('http', {}).get('path', '/')

        if path.endswith('/health'):
            return health_check()
        elif http_method == 'GET':
            return get_tracking(event)
        elif http_method == 'POST':
            return update_tracking(event)
        else:
            return create_response(405, {'error': 'Método no permitido'})

    except Exception as e:
        print(f"Error: {str(e)}")
        error_detail = str(e) if ENVIRONMENT == 'dev' else 'Internal Server Error'
        return create_response(500, {'error': error_detail})


def health_check():
    """Verifica conexión con DynamoDB"""
    try:
        table_status = table.table_status
        return create_response(200, {
            'status': 'healthy',
            'service': 'dinex-tracking',
            'environment': ENVIRONMENT,
            'timestamp': int(datetime.now().timestamp())
        })
    except Exception as e:
        return create_response(503, {'status': 'unhealthy', 'error': str(e)})


def get_tracking(event):
    """
    Consulta tracking por ID
    Query param: tracking_id
    """
    query_params = event.get('queryStringParameters') or {}
    tracking_id = query_params.get('tracking_id')

    if not tracking_id:
        return create_response(400, {'error': 'tracking_id requerido'})

    # TODO: Implementar caché con ElastiCache

    try:
        response = table.query(
            KeyConditionExpression='tracking_id = :tid',
            ExpressionAttributeValues={':tid': tracking_id},
            ScanIndexForward=False,
            Limit=1
        )

        items = response.get('Items', [])
        if not items:
            return create_response(404, {
                'error': 'Tracking no encontrado',
                'tracking_id': tracking_id
            })

        item = items[0]
        tracking_info = {
            'tracking_id': item['tracking_id'],
            'status': item.get('status', 'UNKNOWN'),
            'location': item.get('location', 'Desconocida'),
            'latitude': item.get('latitude'),
            'longitude': item.get('longitude'),
            'timestamp': item.get('timestamp'),
            'notes': item.get('notes', '')
        }

        return create_response(200, tracking_info, use_decimal_encoder=True)

    except Exception as e:
        print(f"DynamoDB error: {str(e)}")
        return create_response(500, {'error': 'Error consultando tracking'})


def update_tracking(event):
    """
    Actualiza ubicación de tracking

    Body JSON:
    {
        "tracking_id": "TRK001",
        "location": "Lima - Centro",
        "latitude": -12.0464,  (opcional)
        "longitude": -77.0428,  (opcional)
        "status": "IN_TRANSIT",  (opcional)
        "notes": "En ruta"  (opcional)
    }
    """
    try:
        body = event.get('body', '{}')
        if isinstance(body, str):
            body = json.loads(body)

        tracking_id = body.get('tracking_id')
        location = body.get('location')

        if not tracking_id or not location:
            return create_response(400, {
                'error': 'tracking_id y location son requeridos'
            })

        # TODO: Validar formato de coordenadas GPS
        # TODO: Validar status contra valores permitidos

        timestamp = int(datetime.now().timestamp())

        item = {
            'tracking_id': tracking_id,
            'timestamp': timestamp,
            'location': location,
            'status': body.get('status', 'IN_TRANSIT'),
            'notes': body.get('notes', ''),
            'expiry': timestamp + (30 * 24 * 60 * 60),  # TTL: 30 días
            'environment': ENVIRONMENT
        }

        # Agregar coordenadas si existen
        if body.get('latitude'):
            item['latitude'] = Decimal(str(body['latitude']))
        if body.get('longitude'):
            item['longitude'] = Decimal(str(body['longitude']))

        table.put_item(Item=item)
        print(f"Tracking actualizado: {tracking_id}")

        # Enviar notificación
        if SNS_TOPIC:
            try:
                send_notification(tracking_id, location, item['status'])
            except Exception as e:
                print(f"SNS error: {str(e)}")

        return create_response(201, {
            'message': 'Tracking actualizado',
            'tracking_id': tracking_id,
            'timestamp': timestamp,
            'location': location
        })

    except json.JSONDecodeError:
        return create_response(400, {'error': 'JSON inválido'})
    except Exception as e:
        print(f"Update error: {str(e)}")
        return create_response(500, {'error': 'Error actualizando tracking'})


def send_notification(tracking_id, location, status):
    """Envía notificación via SNS"""
    # TODO: Usar plantillas HTML para emails
    try:
        message = f"""
Actualización de Tracking - DINEX

Tracking ID: {tracking_id}
Estado: {status}
Ubicación: {location}
Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
        """

        sns.publish(
            TopicArn=SNS_TOPIC,
            Subject=f"Tracking {tracking_id} - {status}",
            Message=message
        )
        print(f"Notificación enviada: {tracking_id}")

    except Exception as e:
        print(f"SNS publish error: {str(e)}")


def create_response(status_code, body, use_decimal_encoder=False):
    """Crea respuesta HTTP para API Gateway"""
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
        },
        'body': json.dumps(
            body,
            cls=DecimalEncoder if use_decimal_encoder else None,
            ensure_ascii=False
        )
    }


# Testing local
if __name__ == '__main__':
    test_event = {
        'requestContext': {'http': {'method': 'GET', 'path': '/tracking'}},
        'queryStringParameters': {'tracking_id': 'TRK001'}
    }
    print(json.dumps(handler(test_event, None), indent=2))
