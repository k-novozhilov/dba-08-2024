create database if not exists lifter_db;

use lifter_db;

create table if not exists migrations
(
    id        int auto_increment
        primary key,
    migration varchar(255) not null,
    batch     int          not null
);

create table if not exists users
(
    id                bigint auto_increment
        primary key,
    name              varchar(255) not null,
    email             varchar(255) not null
        unique,
    email_verified_at datetime,
    password          varchar(255) not null,
    remember_token    varchar(100),
    created_at        datetime,
    updated_at        datetime,
    avatar            varchar(255)
);

create table if not exists password_reset_tokens
(
    email      varchar(255) not null
        primary key,
    token      varchar(255) not null,
    created_at datetime
);

create table if not exists sessions
(
    id            varchar(255) not null
        primary key,
    user_id       bigint,
    ip_address    varchar(45),
    user_agent    text,
    payload       text         not null,
    last_activity int          not null
);

create index if not exists sessions_user_id_index
    on sessions (user_id);

create index if not exists sessions_last_activity_index
    on sessions (last_activity);

create table if not exists moonshine_user_roles
(
    id         bigint auto_increment
        primary key,
    name       varchar(255) not null,
    created_at datetime,
    updated_at datetime
);

create table if not exists moonshine_socialites
(
    id                bigint auto_increment
        primary key,
    moonshine_user_id bigint       not null,
    driver            varchar(255) not null,
    identity          varchar(255) not null,
    created_at        datetime,
    updated_at        datetime,
    constraint moonshine_socialites_driver_identity_unique
        unique (driver, identity)
);