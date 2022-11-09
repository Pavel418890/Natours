# Natours

UI - https://www.natours-club.site

API - https://api.natours-club.site

## Содержание

- [Краткое описание проекта](#summary)
- [Используемые технологии](#tech)
- [Инстуркция по запуску локально](#local-installation)
- [Сценарий для демонстрации возможностей проекта](#description)
- [API документация.](#api-docs)
- [Планы по развитию проекта](#plans)

## <a id="summary">Краткое описание проекта</a>

Natours - web-приложение тур-агенства, которое решает задачи по созданию, продаже и организации туров.

## <a id="tech">Используемые технологии</a>

| Название                                       | Описание                                                                        |
| ---------------------------------------------- | ------------------------------------------------------------------------------- |
| Python 3.10                                    | Язык программирования                                                           |
| Django/Django Rest Framework                   | Web-Фреймворк                                                                   |
| Postgres                                       | База данных                                                                     |
| Docker/Docker-compose                          | Платформа для разработки, доставки и запуска приложения                         |
| Gunicorn + Nginx                               | WSGI + Reverse Proxy `prod`                                                     |
| Celery + RabbitMQ + Redis                      | Инструменты для управления очередями и работы отложенными/асинхронными задачами |
| Flower + RabbitMQ Management UI                | Мониторинг работы воркеров                                                      |
| Stripe                                         | Сервис для оплаты                                                               |
| Sentry                                         | Логирование `prod`                                                              |
| TypeScript                                     | Язык программирования                                                           |
| React                                          | JavaScript-библиотека для создания пользовательских интерфейсов                 |
| Redux Toolkit                                  | Менеджмент состояний приложения                                                 |
| Stripe                                         | Сервис для оплаты                                                               |
| Google Cloud Platform/Google Kubernetes Engine | Хостинг и деплой                                                                |

## <a id="local-installation">Инстуркция по запуску локально</a>

_Необходимые условия:_

- [docker / docker compose v2](https://www.docker.com/products/docker-desktop/)

- [git-cli](https://git-scm.com/downloads)

- [stripe-cli ( `optional `)](https://stripe.com/docs/stripe-cli)

### Клонирование проекта

```shell
git clone https://github.com/Pavel418890/natours.git
git submodule update --remote --init
```

### Настройка переменных окружения

```shell
cp -r environment ./.envs
```

- Заполнить файлы конфигурации `./envs/.env*` своими данными

<details><summary>`Optional` Для тестирования оплаты локально:</summary>

- Написать мне в телеграмм `@pavel418890` или на почту `pavel418890@gmail.com`

для получения УЗ и `{{приватного ключа}}` от stripe аккаунта.

- Установить stripe [stripe-cli](https://stripe.com/docs/stripe-cli).

* <sub>Аутентификация stripe-cli.</sub>

```shell
stripe login

```

- <sub>Запуск вебхука</sub>

```shell
stripe listen --forward-to localhost:8000/v1/bookings/tour-booking/

> OUTPUT:
Ready! Your webhook signing secret is '{{WEBHOOK_SIGNING_SECRET}}' (^C to quit)
```

- <sub>Вставка переменных окружения</sub>

`STRIPE_WEBHOOK_SECRET_KEY=<{{WEBHOOK_SIGNING_SECRET}}>`

`STRIPE_PRIVATE_KEY=<{{приватный ключ}}>`

</details>

### Запуск

- <sub>Переходим в директорию проекта</sub>

```shell
cd ./scripts && ./start.sh
```

## <a id="description">Сценарий для демонстрации возможностей проекта</a>

- **Регистрация**

  Переходим https://www.natours-club.site/signup

  Ввводим почту и пароль

- **Подтверждение почты**

  На почту приходит письмо подтверждения регистрации, переходим по ссыслке указанной в письме

- **Изменение аватара и имени, почты, пароля. (Опционально)**

- **Просмотр подробностей тура**

  Нажимаем в хедере "All Tours"

  Выбираем любой тур и нажимаем "Details"

  Нажимаем "Book tour now"

- **"Покупка" тура**

  Ожидаем ридеректа на страницу оформления покупки(Оформление покупки выполняется в тестовом режиме)

  Выполнить оплату можно только с данными значениями

  `Номер карты:` 4242 4242 4242 4242

  `Срок действия карты:` 24/42

  `CVV/CVC:` 424

  `Имя, фамилия:` Любые

<h3><a id="api-docs">API документация</a><h3>

https://documenter.getpostman.com/view/11170718/UVsPQQrd

<h3><a id="plans">Планы по развитию проекта</a></h3>

1. Написать unit тесты.
1. Настройка CI/CD через Jenkins или Gitlab
1. Чаты. Обмен сообщениями через websoket
1. Разработка пространства для админа/гида
1. Добавить систему фильтров
1. Перенести хранение static и media файлов в Google Storage или S3. На данный момент файлы хранятся в nfs
1. Настройка адаптивной верстки под другие устройства.
1. Доработка всех запросов и проработка дизайна в целом. Возможно добавление фреймворка Next JS, SEO, оптимизация изображений
1. Комментарии в клиенской части
