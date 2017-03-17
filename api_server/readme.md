## 简介

一个简单的基于django-rest-framework的http api。

## 依赖

    Django==1.10.5
    djangorestframework==3.5.3
    jsonfield==1.0.3
    requests==2.12.4

## 安装依赖

    pip install -r requirements.txt

## 使用


初始化数据库

    $ python manage.py makemigrations apis
    $ python manage.py migrate
    数据库为当前目录下的db.sqlite3

启动http api service

    $ sudo python manage.py runserver 80
    服务将监听localhost的80端口。

    Django version 1.10.5, using settings 'api_server.settings'
    Starting development server at http://127.0.0.1:80/
    Quit the server with CONTROL-C.



## 参考资料

- django 用法参考[官方文档](https://docs.djangoproject.com/en/1.10/)
- djangorestframework 用法参考[官方文档](http://www.django-rest-framework.org/)



