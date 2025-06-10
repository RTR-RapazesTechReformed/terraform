import csv
import datetime
import io
import json
import os

import boto3

s3 = boto3.client("s3")
bucket_destino = os.environ.get("BUCKET_RAW", "")


def lambda_handler(event, context):
    try:
        data = json.loads(event["body"])
        ticket_id = data.get("ID_Ticket", "semid")
        timestamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
        filename = f"chamado{ticket_id}_{timestamp}.csv"

        # Criação do CSV em memória
        output = io.StringIO()
        writer = csv.DictWriter(output, fieldnames=data.keys())
        writer.writeheader()
        writer.writerow(data)

        s3.put_object(
            Bucket=bucket_destino,
            Key=filename,
            Body=output.getvalue(),
            ContentType="text/csv",
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"mensagem": "CSV salvo no S3 com sucesso!"}),
        }

    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"erro": str(e)})}
