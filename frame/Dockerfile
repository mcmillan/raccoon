FROM python:3.10-alpine

WORKDIR /app

RUN apk update && apk add gcc musl-dev freetype-dev zlib-dev jpeg-dev

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY . ./

CMD ["python", "frame.py"]
