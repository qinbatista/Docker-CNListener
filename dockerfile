FROM python:3.8.13-alpine3.16 as python

COPY . /

#[Start] CNListener--------------------------------------------------
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt
ARG AWS_KEY
ARG AWS_SECRET

RUN apk add aws-cli
RUN aws configure set aws_access_key_id ${AWS_KEY}
RUN aws configure set aws_secret_access_key ${AWS_SECRET}
RUN aws configure set default.region us-west-2
RUN aws configure set region us-west-2 --profile testing

RUN apk add curl
#[End] CNListener--------------------------------------------------

WORKDIR /
RUN apk add supervisor
RUN echo "[supervisord]" > /etc/supervisord.conf \
    && echo "nodaemon=true" >> /etc/supervisord.conf \
    && echo "[program:CNListener]" >> /etc/supervisord.conf \
    && echo "command=python3 /CNListener.py" >> /etc/supervisord.conf \

#7171 for CN server listenning
EXPOSE 7171/udp
CMD ["supervisord", "-c", "/etc/supervisord.conf"]