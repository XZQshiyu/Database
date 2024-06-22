drop database if exists banksystem;
create database banksystem;


use banksystem;

drop table if exists Bank;
drop table if exists department;
drop table if exists employee;
drop table if exists client;
drop table if exists loan;
drop table if exists pay_loan;
drop table if exists credit_account;
drop table if exists saving_account;
drop table if exists client_credit_account;
drop table if exists client_saving_account;


create table Bank
(
    bank_name   varchar(30) primary key,
    location    varchar(30) not null,
    asset       float not null,
    image       VARCHAR(255)
);

create table department
(
    department_id   varchar(18) primary key,
    bank_name       varchar(30) not null,
    department_name varchar(30) not null,
    department_type varchar(30) not null,
    foreign key (bank_name) references Bank(bank_name) ON DELETE CASCADE
);

create table employee
(
    employee_id     varchar(18) primary key,
    department_id   varchar(18) not null,
    id              varchar(18) not null,
    name            varchar(30) not null,
    sex             varchar(1)  not null,
    phone           varchar(30) not null,
    address         varchar(30) not null,
    start_work_date date    not null,
    foreign key(department_id)  references  department(department_id) ON DELETE CASCADE
);

create table client 
(
    client_id   varchar(18) primary key,
    id          varchar(18) not null,
    name        varchar(30) not null,
    sex         varchar(1)  not null,
    address     varchar(30) not null,
    phone       varchar(30) not null,
    email       varchar(30) not null,
    contact_name    varchar(30) not null,
    contact_phone   varchar(20) not null,
    contact_email   varchar(30) not null,
    contact_relation    varchar(20) not null
);

create table loan
(
    loan_id     varchar(32) primary key,
    client_id   varchar(18) not null,
    bank_name   varchar(30) not null,
    loan_money  float   not null,
    loan_rate   float   not null,
    loan_date   date    not null,
    foreign key(client_id)  references  client(client_id) ON DELETE CASCADE,
    foreign key(bank_name)  references  Bank(bank_name) ON DELETE CASCADE      
);

create table pay_loan
(
    pay_id      integer not null,
    pay_money   float   not null,
    pay_date    date    not null,
    loan_id     varchar(32) not null,
    primary key (pay_id, loan_id)  ,
    foreign key (loan_id) references loan(loan_id) ON DELETE CASCADE
);

create table credit_account 
(
    account_id  char(18)    primary key,
    bank_name   varchar(30) not null,
    balance     float   not null,
    open_date   date    not null,
    overdraft   float   not null,
    foreign key (bank_name) references  Bank(bank_name) ON DELETE CASCADE
);

create table saving_account
(
    account_id char(18) primary key,
    bank_name   varchar(30) not null,
    balance     float   not null,
    open_date   date    not null,
    rate        float   not null,
    foreign key (bank_name) references  Bank(bank_name) ON DELETE CASCADE
);

create table client_credit_account
(
    client_id   varchar(18) not null,
    account_id  char(18)    not null,
    lateset_visit_date date,
    primary key (client_id, account_id),
    foreign key (client_id) references client(client_id) ON DELETE CASCADE,
    foreign key (account_id) references credit_account(account_id) ON DELETE CASCADE
);

create table client_saving_account
(
    client_id   varchar(18) not null,
    account_id  char(18)    not null,
    lateset_visit_date date,
    primary key (client_id, account_id),
    foreign key (client_id) references client(client_id) ON DELETE CASCADE,
    foreign key (account_id) references saving_account(account_id) ON DELETE CASCADE
);
