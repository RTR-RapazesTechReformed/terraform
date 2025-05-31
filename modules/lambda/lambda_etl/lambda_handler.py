import io
import json
import os

import boto3
import pandas as pd

bucket_destino = os.environ.get("BUCKET_DESTINO", "")

s3 = boto3.client("s3")


def lambda_handler(event, context):
    # Obtém informações do evento
    record = event["Records"][0]
    bucket_raw = record["s3"]["bucket"]["name"]
    file_key = record["s3"]["object"]["key"]

    # Nome do bucket de destino
    bucket_trusted = bucket_destino

    try:
        # Baixa o arquivo do S3
        response = s3.get_object(Bucket=bucket_raw, Key=file_key)
        file_content = response["Body"].read()

        # Lê o CSV com Pandas
        df = pd.read_csv(io.BytesIO(file_content), encoding="utf-8")

        """ 🔹 Tratamento de dados """
        # limpa os valores nulos do dataframe
        df_nan = df.dropna()
        # separa em dataframes
        # Esse é de clientes Premium
        df_premium = df_nan[df_nan["plano"] == "Premium"]
        # Esse é de clientes Normais
        df_free = df_nan[df_nan["plano"] == "Free"]

        # ordena os dataframes por loja em ordem alfabética
        df_premium = df_premium.sort_values(by="loja")
        df_free = df_free.sort_values(by="loja")

        # Convertendo os DataFrames para CSVs separados
        premium_buffer = io.BytesIO()
        free_buffer = io.BytesIO()

        df_premium.to_csv(premium_buffer, index=False, encoding="utf-8")
        df_free.to_csv(free_buffer, index=False, encoding="utf-8")

        premium_buffer.seek(0)
        free_buffer.seek(0)

        # Salvando os arquivos no bucket trusted com nomes diferentes
        premium_key = f"premium/{file_key}"
        free_key = f"free/{file_key}"

        s3.put_object(
            Bucket=bucket_trusted, Key=premium_key, Body=premium_buffer.getvalue()
        )
        s3.put_object(Bucket=bucket_trusted, Key=free_key, Body=free_buffer.getvalue())

        print(
            f"Arquivo {file_key} processado e salvo como {premium_key} e {free_key} no {bucket_trusted}"
        )

        return {
            "statusCode": 200,
            "body": f"Arquivo {file_key} processado com sucesso e salvo em {bucket_trusted}",
        }

    except Exception as e:
        print(f"Erro ao processar o arquivo {file_key}: {str(e)}")
