import json
import os

import boto3

sns_topic_arn = os.environ.get("SNS_TOPIC_ARN", "")
email_list_str = os.environ.get("EMAIL_LIST", "")
email_list = email_list_str.split(",")

sns_client = boto3.client("sns")


def lambda_handler(event, context):
    """Envio de mensagem personalizada ao SNS com HTML estilizado para a RTR"""

    resultado = {
        "status": "Sucesso",
        "usuario": "edson.nogueira@sptech.school",
        "acao": "Processamento de dados de lojas",
    }

    mensagem_formatada = f"""
💡 *Notificação da Plataforma RTR*

Olá! A função **AWS Lambda** foi executada com sucesso pelo serviço da **RTR**.

📄 **Detalhes da execução:**
- **Status:** {resultado['status']}
- **Usuário:** {resultado['usuario']}
- **Ação executada:** {resultado['acao']}

📦 O CSV contendo as **lojas atendidas** já está disponível para visualização e uso no bucket de destino.

❓ Caso tenha dúvidas ou precise de suporte, entre em contato com a equipe da RTR.

Atenciosamente,
**Sistema Automatizado RTR** 🤖
"""

    for email in email_list:
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=mensagem_formatada,
            Subject="[RTR Notificação] CSV das lojas disponível 🎯",
            MessageAttributes={"email": {"DataType": "String", "StringValue": email}},
        )

    return {"statusCode": 200, "body": json.dumps("Notificação enviada com sucesso!")}
