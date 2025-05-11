# teyka

### Схема базы данных

CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE IF NOT EXISTS "templates"
(
	id INTEGER not null
		constraint template_pk
			primary key autoincrement,
	name varchar(255) not null,
	discount int not null,
	cashback int not null
);
CREATE UNIQUE INDEX template_id_uindex
	on "templates" (id);
CREATE TABLE IF NOT EXISTS "users"
(
	id INTEGER not null
		constraint user_pk
			primary key autoincrement,
	template_id INT not null
		constraint template_id
			references "templates",
	name varchar(255) not null
, bonus numeric);
CREATE UNIQUE INDEX user_id_uindex
	on "users" (id);
CREATE TABLE IF NOT EXISTS "products"
(
	id INTEGER not null
		constraint table_name_pk
			primary key autoincrement,
	name varchar(255) not null,
	type varchar(255),
	value varchar(255)
);
CREATE UNIQUE INDEX table_name_id_uindex
	on "products" (id);
CREATE TABLE IF NOT EXISTS "operations"
(
	id INTEGER not null
		constraint operation_pk
			primary key autoincrement,
	user_id INT not null
		references "users",
	cashback numeric not null,
	cashback_percent numeric not null,
	discount numeric not null,
	discount_percent numeric not null,
	write_off numeric,
	check_summ numeric not null,
	done boolean
, allowed_write_off numeric);
CREATE UNIQUE INDEX operation_id_uindex
	on "operations" (id);
