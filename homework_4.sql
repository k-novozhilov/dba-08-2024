create database lifter_db
    with owner lifter_user;

create table public.migrations
(
    id        serial
        primary key,
    migration varchar(255) not null,
    batch     integer      not null
);

alter table public.migrations
    owner to lifter_user;

create table public.users
(
    id                bigserial
        primary key,
    name              varchar(255) not null,
    email             varchar(255) not null
        constraint users_email_unique
            unique,
    email_verified_at timestamp(0),
    password          varchar(255) not null,
    remember_token    varchar(100),
    created_at        timestamp(0),
    updated_at        timestamp(0),
    avatar            varchar(255)
);

alter table public.users
    owner to lifter_user;

create table public.password_reset_tokens
(
    email      varchar(255) not null
        primary key,
    token      varchar(255) not null,
    created_at timestamp(0)
);

alter table public.password_reset_tokens
    owner to lifter_user;

create table public.sessions
(
    id            varchar(255) not null
        primary key,
    user_id       bigint,
    ip_address    varchar(45),
    user_agent    text,
    payload       text         not null,
    last_activity integer      not null
);

alter table public.sessions
    owner to lifter_user;

create index sessions_user_id_index
    on public.sessions (user_id);

create index sessions_last_activity_index
    on public.sessions (last_activity);

create table public.moonshine_user_roles
(
    id         bigserial
        primary key,
    name       varchar(255) not null,
    created_at timestamp(0),
    updated_at timestamp(0)
);

alter table public.moonshine_user_roles
    owner to lifter_user;

create table public.moonshine_users
(
    id                     bigserial
        primary key,
    moonshine_user_role_id bigint default '1'::bigint not null
        constraint moonshine_users_moonshine_user_role_id_foreign
            references public.moonshine_user_roles
            on update cascade on delete cascade,
    email                  varchar(190)               not null
        constraint moonshine_users_email_unique
            unique,
    password               varchar(255)               not null,
    name                   varchar(255)               not null,
    avatar                 varchar(255),
    remember_token         varchar(100),
    created_at             timestamp(0),
    updated_at             timestamp(0)
);

alter table public.moonshine_users
    owner to lifter_user;

create table public.moonshine_socialites
(
    id                bigserial
        primary key,
    moonshine_user_id bigint       not null,
    driver            varchar(255) not null,
    identity          varchar(255) not null,
    created_at        timestamp(0),
    updated_at        timestamp(0),
    constraint moonshine_socialites_driver_identity_unique
        unique (driver, identity)
);

alter table public.moonshine_socialites
    owner to lifter_user;

create table public.moonshine_user_permissions
(
    id                bigserial
        primary key,
    moonshine_user_id bigint not null,
    permissions       json   not null,
    created_at        timestamp(0),
    updated_at        timestamp(0)
);

alter table public.moonshine_user_permissions
    owner to lifter_user;

create table public.employees
(
    id         bigserial
        primary key,
    name       varchar(255) not null,
    surname    varchar(255) not null,
    patronymic varchar(255),
    email      varchar(255) not null,
    post       varchar(255),
    division   varchar(255) not null,
    bitrix_id  integer,
    deleted_at timestamp(0),
    created_at timestamp(0),
    updated_at timestamp(0)
);

alter table public.employees
    owner to lifter_user;

create table public.accounts
(
    id           bigserial
        primary key,
    name         varchar(255) not null,
    login        varchar(255) not null,
    password     varchar(255) not null,
    deleted_at   timestamp(0),
    created_at   timestamp(0),
    updated_at   timestamp(0),
    password_api varchar(255)
);

alter table public.accounts
    owner to lifter_user;

create table public.projects
(
    id         bigserial
        primary key,
    bitrix_id  integer,
    name       varchar(255) not null,
    link_repo  varchar(255),
    type       varchar(255),
    deleted_at timestamp(0),
    created_at timestamp(0),
    updated_at timestamp(0),
    backup_url varchar(255),
    slug       varchar(255),
    account_id bigint
        constraint projects_account_id_foreign
            references public.accounts
            on update cascade on delete cascade
);

alter table public.projects
    owner to lifter_user;

create table public.employees_projects
(
    id          bigserial
        primary key,
    employee_id bigint not null
        constraint employees_projects_employee_id_foreign
            references public.employees,
    project_id  bigint not null
        constraint employees_projects_project_id_foreign
            references public.projects
);

alter table public.employees_projects
    owner to lifter_user;

create table public.configurations
(
    id               bigserial
        primary key,
    beget_id         varchar(255) not null,
    name             varchar(255) not null,
    cpu_count        integer      not null,
    disk_size        integer      not null,
    memory           integer      not null,
    bandwidth_public integer      not null,
    price_day        integer      not null,
    price_month      integer      not null,
    available        boolean      not null,
    custom           boolean      not null,
    configurable     boolean      not null,
    region           varchar(255) not null,
    deleted_at       timestamp(0),
    created_at       timestamp(0),
    updated_at       timestamp(0)
);

alter table public.configurations
    owner to lifter_user;

create table public.servers
(
    id               bigserial
        primary key,
    name             varchar(255)          not null,
    project_id       bigint                not null,
    employee_id      bigint,
    ip               varchar(255),
    domain           varchar(255),
    beget_id         uuid,
    status           varchar(255),
    created_at       timestamp(0),
    updated_at       timestamp(0),
    configuration_id bigint
        constraint servers_configuration_id_foreign
            references public.configurations
            on update cascade on delete cascade,
    creator_id       bigint                not null,
    subdomain_id     integer,
    is_custom_config boolean default false not null,
    cpu_count        integer,
    disk_size        integer,
    memory           integer
);

alter table public.servers
    owner to lifter_user;

create table public.failed_jobs
(
    id         bigserial
        primary key,
    uuid       varchar(255)                           not null
        constraint failed_jobs_uuid_unique
            unique,
    connection text                                   not null,
    queue      text                                   not null,
    payload    text                                   not null,
    exception  text                                   not null,
    failed_at  timestamp(0) default CURRENT_TIMESTAMP not null
);

alter table public.failed_jobs
    owner to lifter_user;

create table public.ssh_keys
(
    id          bigserial,
    employee_id bigint not null,
    project_id  bigint not null,
    ssh_key     text   not null,
    beget_id    integer,
    name        varchar(255),
    fingerprint varchar(255),
    primary key (employee_id, project_id)
);

alter table public.ssh_keys
    owner to lifter_user;

create table public.permissions
(
    id         bigserial
        primary key,
    name       varchar(255) not null,
    guard_name varchar(255) not null,
    created_at timestamp(0),
    updated_at timestamp(0),
    constraint permissions_name_guard_name_unique
        unique (name, guard_name)
);

alter table public.permissions
    owner to lifter_user;

create table public.roles
(
    id            bigserial
        primary key,
    name          varchar(255) not null,
    guard_name    varchar(255) not null,
    created_at    timestamp(0),
    updated_at    timestamp(0),
    role_priority json,
    constraint roles_name_guard_name_unique
        unique (name, guard_name)
);

alter table public.roles
    owner to lifter_user;

create table public.model_has_permissions
(
    permission_id bigint       not null
        constraint model_has_permissions_permission_id_foreign
            references public.permissions
            on delete cascade,
    model_type    varchar(255) not null,
    model_id      bigint       not null,
    primary key (permission_id, model_id, model_type)
);

alter table public.model_has_permissions
    owner to lifter_user;

create index model_has_permissions_model_id_model_type_index
    on public.model_has_permissions (model_id, model_type);

create table public.model_has_roles
(
    role_id    bigint       not null
        constraint model_has_roles_role_id_foreign
            references public.roles
            on delete cascade,
    model_type varchar(255) not null,
    model_id   bigint       not null,
    primary key (role_id, model_id, model_type)
);

alter table public.model_has_roles
    owner to lifter_user;

create index model_has_roles_model_id_model_type_index
    on public.model_has_roles (model_id, model_type);

create table public.role_has_permissions
(
    permission_id bigint not null
        constraint role_has_permissions_permission_id_foreign
            references public.permissions
            on delete cascade,
    role_id       bigint not null
        constraint role_has_permissions_role_id_foreign
            references public.roles
            on delete cascade,
    primary key (permission_id, role_id)
);

alter table public.role_has_permissions
    owner to lifter_user;

create table public.notifications
(
    id              uuid         not null
        primary key,
    type            varchar(255) not null,
    notifiable_type varchar(255) not null,
    notifiable_id   bigint       not null,
    data            text         not null,
    read_at         timestamp(0),
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table public.notifications
    owner to lifter_user;

create index notifications_notifiable_type_notifiable_id_index
    on public.notifications (notifiable_type, notifiable_id);

