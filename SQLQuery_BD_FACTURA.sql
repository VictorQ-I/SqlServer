--- Se crea base de datos
CREATE DATABASE CONSULTA
go

USE CONSULTA
go

---Se crea las tablas
CREATE TABLE Registro(
IdRegistro int identity (1,1) primary key,
Nombre varchar(30),
Apellido varchar(30),
Correo varchar(100),
Telefono varchar(11)
)
go

CREATE TABLE Direccion(
IdDireccion int identity (1,1) primary key,
IdRegistro int,
Direccion varchar(100),
IdDepartamento int,
IdCiudad int,
CodigoPostal varchar(30)
)

CREATE TABLE Productos(
IdProductos int identity (1,1) primary key,
IdCategoria int,
Nombre_Producto varchar(30),
Stock int,
Precio int
)
go

CREATE TABLE Categoria(
IdCategoria int identity(1,1) primary key,
Categoria varchar(50)
)
go

create TABLE Venta(
IdVenta int identity(1,1) primary key,
IdCliente int,
Fecha_Venta date,
Total int,
Estado varchar(10)
)
go

CREATE TABLE Detalle_venta(
IdDetalle int identity(1,1)  primary key,
IdVenta int,
IdProductos int,
IdCliente int,
Presentacion varchar(100),
Cantidad int,
Precio_venta int,
Total int,
)
go

CREATE TABLE Usuario(
IdUsuario int identity(1,1)  primary key,
Nombre varchar(50),
Usuario varchar(50),
Contraseña varchar(30),
TipoUsuario varchar(30)
)
go

CREATE TABLE Departamento(
IdDepartamento int identity(1,1)  primary key,
Departamento varchar(50),
)
go

CREATE TABLE Ciudad(
IdCiudad int identity(1,1)  primary key,
IdDepartamento int,
Ciudad varchar(50),
)
go

--se hace consulta para traer las ventas registradas 
SELECT d.IdDetalle, v.Fecha_Venta, concat(r.Nombre, ' ', r.Apellido) AS Nombre, p.Nombre_Producto, d.Cantidad, p.Precio AS Precio_Unidad, (d.Cantidad * d.Precio_venta) AS Total
FROM Detalle_venta AS d
INNER JOIN Venta as v ON v.IdVenta = d.Idventa
INNER JOIN Registro AS r ON r.IdRegistro = v.IdCliente
INNER JOIN Productos as p ON p.IdProductos = d.IdProductos

SELECT * FROM Detalle_venta
SELECT * FROM Registro
SELECT * FROM Venta
SELECT * FROM Productos
go

--- consulta de cada tabla individual
select * from Registro
select * from Productos
select * from Ventas
select * from Lista
go

---Se modifica alguna o registro de una tabla
alter table Lista alter column Fecha DateTime 
go

--- Se elimina un registro por fila
delete from Lista where Id = 11
delete from Registro where IdRegistro = 49
delete from Ventas where IdVentas = 8
delete from Venta where IdVenta = @IdVenta
go

--- Se modifica un dato registrada en dicha tabla
update Registro set Apellido = 'Gomoz Lopez' where IdRegistro = 2
go

---Se modifica una columna de una tabla
ALTER TABLE Lista ALTER COLUMN Fecha Date;
go

---Indicamos que las llaves foraneas seas deshabilitadas para poder hacer cualquier acción en cualquier tabla
alter table Ventas
nocheck constraint fk_Registros
alter table Ventas
nocheck constraint fk_Productos
go

---Se verifica que si se haya deshabilitado
exec sp_helpconstraint Ventas

alter table Lista
nocheck constraint fk_Registro
alter table Lista
nocheck constraint fk_Ventas

exec sp_helpconstraint Ventas
go

SELECT r.IdRegistro, concat(r.Nombre, ' ', r.Apellido) AS Nombre, v.IdVentas, p.Nombre_Producto, v.Cantidad, p.Precio AS Precio_Unidad
FROM Ventas AS v
INNER JOIN Registro AS r ON r.IdRegistro = v.IdRegistro
INNER JOIN Productos p ON p.IdProductos = v.IdProductos
go

delete Registro where IdRegistro between 1 and 40
delete Productos where Idproductos between 1 and 100
delete Venta where IdVenta between 1 and 100
delete Detalle_venta where IdDetalle between 1 and 100
delete Departamento where IdDepartamento between 1 and 100
delete Ciudad where IdCiudad between 167 and 212
delete Direccion where IdDireccion between 1 and 212
go

delete from Detalle_venta where IdDetalle = 2
go

---Me trae los registr que esten duplicado con su cantidad
select Nombre, Correo, count(*) as countof
from Registro
group by Nombre, Correo 
HAVING count(*) >= 1
go

-----------------------------------------------------------------Procedimiento almacenado para agregar una venta-------------------------------------------------------------------------------------

---Agregar una venta
create Procedure AgregarVenta
@IdCliente int,
@IdUsuario int,
@Fecha_Venta date,
@Total int,
@Estado varchar(10)
as
insert into Venta (IdCliente, IdUsuario, Fecha_Venta, Total, Estado)
values(@IdCliente, @IdUsuario, @Fecha_Venta, @Total, @Estado)
go

---Anular venta
create Procedure AnularVenta
@IdVenta int
as
delete from Venta
where IdVenta = @IdVenta
delete from Detalle_venta 
where IdVenta = @IdVenta
go

---Agregar detalle venta
create Procedure AgregarDetalleventa
@IdVenta int,
@IdProductos int,
@IdCliente int,
@Presentacion varchar(100),
@Cantidad int,
@Precio_Venta int,
@Total int
as
insert into Detalle_Venta (IdVenta, IdProductos, IdCliente, Presentacion, Cantidad, Precio_Venta, Total)
values (@IdVenta, @IdProductos, @IdCliente, @Presentacion, @Cantidad, @Precio_Venta, @Total)
update Productos set Stock = Stock - @Cantidad where IdProductos = @IdProductos
go

---Anular detalle venta
create Procedure AnularDetalleVenta
@IdVenta int,
@IdProductos int,
@IdCliente int,
@Presentacion varchar(10),
@Cantidad int,
@Precio_Venta int,
@Total int
as
update Detalle_venta set IdProductos = @IdProductos, IdCliente = @IdCliente, Presentacion = @Presentacion, Total = @Total
where IdVenta = @IdVenta
go

---Mostrar detalle venta
create procedure MostrarDetalleventa
@IdVenta int
as
select DV.IdDetalle, P.IdProductos, DV.Presentacion as Producto, DV.Cantidad, 
DV.Precio_venta as 'Precio Unitario', (DV.Cantidad * DV.Precio_venta) AS 'Total' 
from Detalle_venta DV
INNER JOIN Productos P ON DV.IdProductos = p.IdProductos
where DV.IdVenta = @IdVenta
go

---Buscar producto
create Proc Buscar_Producto
@Buscar varchar(50)
as
select * from Productos 
where IdProductos Like @Buscar + '%' and Nombre_Producto Like @Buscar + '%' and Stock Like @Buscar + '%'
and Precio Like @Buscar + '%'
go

---Mostra venta cliente
create procedure MostrarVentaCliente
@Buscar nvarchar(100)
as
select v.IdVenta, concat(r.Nombre,' ',r.Apellido) as Nombre, v.Fecha_Venta, v.Total
from Venta v
INNER JOIN Registro r on v.IdCliente = r.IdRegistro
where r.Nombre like @Buscar + '$'
go

---Mostrar venta
create procedure MostrarVenta
as
select v.IdVenta, concat(r.Nombre,' ',r.Apellido) as Nombre, v.Fecha_Venta, v.Total, v.Estado, u.Nombre as Usuario
from Venta v
INNER JOIN Registro r on v.IdCliente = r.IdRegistro
inner join Usuario u on v.IdUsuario = u.IdUsuario
go

create procedure ContarCantidadRegistrosVentas
as
SELECT ISNULL(MAX(IdVenta), 0) + 1 AS IDNuevo from Venta;
go

---Buscar venta por fecha
create procedure BuscarVentaFecha
@FechaInicio date,
@FechaFin date
as
select v.IdVenta, concat(r.Nombre,' ',r.Apellido) as Nombre, v.Fecha_Venta, v.Total, v.Estado, u.Nombre as Usuario
from Venta v
INNER JOIN Registro r on v.IdCliente = r.IdRegistro
inner join Usuario u on v.IdUsuario = u.IdUsuario
where v.Fecha_Venta BETWEEN @FechaInicio AND @FechaFin
go

---Buscar venta de los ultimos 7 días
create procedure BuscarVentaSemana
as
select v.IdVenta, concat(r.Nombre,' ',r.Apellido) as Nombre, v.Fecha_Venta, v.Total, v.Estado, u.Nombre as Usuario
from Venta v
INNER JOIN Registro r on v.IdCliente = r.IdRegistro
inner join Usuario u on v.IdUsuario = u.IdUsuario
where Fecha_Venta >= dateadd (dd, -7, getdate())
go

---Buscar venta de los ultimos 30 días
create procedure BuscarVentaMes
as
select v.IdVenta, concat(r.Nombre,' ',r.Apellido) as Nombre, v.Fecha_Venta, v.Total, v.Estado, u.Nombre as Usuario
from Venta v
INNER JOIN Registro r on v.IdCliente = r.IdRegistro
inner join Usuario u on v.IdUsuario = u.IdUsuario
where Fecha_Venta >= dateadd (dd, -30, getdate())
go

---Buscar venta de mes actual
create procedure BuscarVentaMesActual
as
select v.IdVenta, concat(r.Nombre,' ',r.Apellido) as Nombre, v.Fecha_Venta, v.Total, v.Estado, u.Nombre as Usuario
from Venta v
INNER JOIN Registro r on v.IdCliente = r.IdRegistro
inner join Usuario u on v.IdUsuario = u.IdUsuario
Where datepart(mm, Fecha_Venta) = datepart(mm, getdate())
go

---Agregar registro cliente
create Procedure AgregarReistroCliente
@Nombre varchar(30),
@Apellido varchar(30),
@Correo varchar(100),
@Telefono varchar(11)
as
insert into Registro (Nombre, Apellido, Correo, Telefono)
values(@Nombre, @Apellido, @Correo, @Telefono)
go

---Sumar un ID a un registro de la tabla Registro para guardar dirección
create procedure ContarCantidadRegistrosClientes
as
DECLARE @NextIdentity INT;
SET @NextIdentity = IDENT_CURRENT('Registro') + 1;
SELECT @NextIdentity AS NextIdentity;
go

---Mostrar registro cliente
create procedure Mostrar_Registro_Cliente
as
select d.IdRegistro, r.Nombre, r.Apellido, r.Correo, r.Telefono, d.Direccion, d.IdDepartamento, de.Departamento, d.IdCiudad, c.Ciudad, d.CodigoPostal
from Direccion d 
inner join Registro r on d.IdRegistro = r.IdRegistro
inner join Departamento de on d.IdDepartamento = de.IdDepartamento
inner join Ciudad c on d.IdCiudad = c.IdCiudad
GROUP BY d.IdRegistro, r.Nombre, r.Apellido, r.Correo, r.Telefono, d.Direccion, d.IdDepartamento, de.Departamento, d.IdCiudad, c.Ciudad, d.CodigoPostal
go

---Anular registro cliente
create Procedure AnularReistroCliente
@IdCliente int
as
delete from Registro
where IdRegistro = @IdCliente
delete from Direccion
where IdRegistro = @IdCliente
go

---Editar registro cliente
create Procedure EditarReistroCliente
@IdRegistro int,
@Nombre varchar(30),
@Apellido varchar(30),
@Correo varchar(100),
@Telefono varchar(11),
@Direccion varchar(100),
@IdDepartamento int,
@IdCiudad int,
@CodigoPostal varchar(30)
as
update Registro set Nombre = @Nombre, Apellido = @Apellido, Correo = @Correo, Telefono = @Telefono
where IdRegistro = @IdRegistro
update Direccion set Direccion = @Direccion, IdDepartamento = @IdDepartamento, IdCiudad = @IdCiudad, CodigoPostal = @CodigoPostal
where IdRegistro = @IdRegistro
go

---Agregar registro dirección
create proc Agregar_Direccion
@IdRegistro int,
@Direccion varchar(100),
@IdDepartamento int,
@IdCiudad int,
@CodigoPostal varchar(30)
as
insert into Direccion (IdRegistro, Direccion,  IdDepartamento, IdCiudad, CodigoPostal)
values(@IdRegistro, @Direccion,  @IdDepartamento, @IdCiudad, @CodigoPostal)
go

---Anular registro dirección
create proc Anular_Direccion
@IdDireccion int
as
delete from Direccion
where IdDireccion = @IdDireccion
go

---Editar registro dirección
create Procedure Editar_Direccion
@IdDireccion int,
@IdRegistro int,
@Direccion varchar(100),
@IdDepartamento int,
@IdCiudad int,
@CodigoPostal varchar(30)
as
update Direccion set IdRegistro = @IdRegistro, Direccion = @Direccion, IdDepartamento = @IdCiudad, IdCiudad = @IdDepartamento, CodigoPostal = @CodigoPostal
where IdDireccion = @IdDireccion
go

---Agregar registro productos
create Procedure AgregarReistroProducto
@IdCategoria int,
@Nombre_Producto varchar(30),
@Stock int,
@Precio int
as
insert into Productos (IdCategoria, Nombre_Producto, Stock, Precio)
values(@IdCategoria, @Nombre_Producto, @Stock,  @Precio)
go

--Mostrar productos
create proc Mostrar_Productos
as
select p.IdProductos, p.Nombre_Producto, c.IdCategoria, c.Categoria, p.Stock, p.Precio
from Productos p
inner join Categoria c on p.IdCategoria = c.IdCategoria
go

---Anular registro productos
create Procedure AnularReistroProductos
@IdProductos int
as
delete from Productos
where IdProductos = @IdProductos
go

---Editar registro productos
create Procedure EditarReistroProductos
@IdProductos int,
@IdCategoria int,
@Nombre_Producto varchar(30),
@Stock int,
@Precio int
as
update Productos set IdCategoria = @IdCategoria, Nombre_Producto = @Nombre_Producto, Stock = @Stock, Precio = @Precio
where IdProductos = @IdProductos
go

---Agregar categía producto
create proc Agregar_Categoria
@Categoria varchar(50)
as
insert into Categoria (Categoria)
values (@Categoria)
go

--Mostrar categorías
create proc Mostrar_Categorias
as
select *
from Categoria
go

---- Eliminar categoría prodcutos
create proc Eliminar_Categoria
@IdCategoria int
as
delete from Categoria
where IdCategoria = @IdCategoria
go

---Editar categía producto
create proc Editar_Categoria
@IdCategoria int,
@Categoria varchar(50)
as
update Categoria set Categoria = @Categoria
where IdCategoria = @IdCategoria
go

---Mostrar factura
create proc Mostrar_Factura
@IdVenta int
as
select concat(r.Nombre, ' ', r.Apellido) as Nombre, r.Correo, r.Telefono, d.IdVenta as NoFactura,
v.Fecha_Venta as Fecha, v.Total, v.Estado, d.Presentacion as Producto, d.Cantidad, d.Precio_Venta, d.Total, u.Nombre as Usuario
from Venta v
inner join Detalle_venta d on v.IdVenta = d.IdVenta
inner join Registro r on v.IdCliente = r.IdRegistro
inner join Usuario u on v.IdUsuario = u.IdUsuario
inner join Productos p on d.IdProductos = p.IdProductos
where v.IdVenta = @IdVenta
go

--Crear cuenta usuario
create proc Crear_Cuenta_Usuario
@Nombre varchar(50),
@Usuario varchar(50),
@Contraseña varchar(30),
@TipoUsuario varchar(30)
as
insert into Usuario (Nombre, Usuario, Contraseña, TipoUsuario)
values (@Nombre, @Usuario, @Contraseña, @TipoUsuario)
go

--Mostrar cuenta usuario
create proc Mostrar_Cuenta_Usuario
as
select * From Usuario
go

---Inciar Sesión
create proc  Inciar_Sesion
@Usuario varchar(50),
@Contraseña varchar(30)
as
select Nombre
From Usuario
Where Usuario = @Usuario and Contraseña = @Contraseña
go

---Eliminar cuenta Sesión
create proc Eliminar_Cuenta_Usuario
@Idusuario int
as
delete from Usuario
where IdUsuario = @Idusuario
go

---Editar cuenta Sesión
create proc Editar_Cuenta_Usuario
@IdUsuario int,
@Nombre varchar(50),
@Usuario varchar(30),
@Contraseña varchar(30),
@TipoUsuario varchar(30)
as
update Usuario set Nombre = @Nombre, Usuario = @Usuario, Contraseña = @Contraseña, TipoUsuario = @TipoUsuario
where IdUsuario = @IdUsuario
go

---Agregar departamento
create proc Agregar_Departamento
@Departamento varchar(50)
as
insert into Departamento (Departamento)
values (@Departamento)
go

--Mostrar Departamento
create proc Mostrar_Departamento
as
select *
from Departamento
go

---- Eliminar Departamento
create proc Eliminar_Departamento
@IdDepartamento int
as
delete from Departamento
where IdDepartamento = @IdDepartamento
go

---Editar Departamento
create proc Editar_Departamento
@IdDepartamento int,
@Departamento varchar(50)
as
update Departamento set Departamento = @Departamento
where IdDepartamento = @IdDepartamento
go

---Agregar Ciudad
create proc Agregar_Ciudad
@IdDepartamento int,
@Ciudad varchar(50)
as
insert into Ciudad (IdDepartamento, Ciudad)
values (@IdDepartamento , @Ciudad)
go

--Mostrar Ciudad
create proc Mostrar_Ciudad
@IdDepartamento int
as
select *
from Ciudad
where IdDepartamento = @IdDepartamento
go

---- Eliminar Ciudad
create proc Eliminar_Ciudad
@IdCiudad int
as
delete from Ciudad
where IdCiudad = @IdCiudad
go

---Editar Ciudad
create proc Editar_Ciudad
@IdCiudad int,
@IdDepartamento int,
@Ciudad varchar(50)
as
update Ciudad set IdDepartamento = @IdDepartamento, Ciudad = @Ciudad
where IdCiudad = @IdCiudad
go

---Consultar departamento y ciudad
create proc Consultar_Departamento_Ciudad
@IdDepartamento int
as
select d.IdDepartamento, d.Departamento, c.IdCiudad, c.Ciudad
from Ciudad c
inner join Departamento d on c.IdDepartamento = d.IdDepartamento
where d.IdDepartamento = @IdDepartamento
go

-----------------------------------------------------------------PROCEDIMIENTOS ALMACENADOS ESTADISTICAS-------------------------------------------------------------------------------------
CREATE PROC ContarCantidadRegistros
@TotalVentas int out,
@CantidadClientes int out,
@CantidadProductos int out
as
---Total de las ventas
set @TotalVentas = (select sum(Total) as TotalVentas from Venta)
--Cantidad de clientes registrados
set @CantidadClientes = (select count(IdRegistro) as CantidadClientes  from Registro)
--Cantidad de productos existentess
set @CantidadProductos = (select count(IdProductos) as CantidadProductos  from Productos)
go

---Mostrar producto mas vendidos
create proc ProductosMasVendidos
as
select top 50 p.Nombre_Producto as Producto, count(p.IdProductos) as CantidadVendida
from Detalle_venta as dv
inner join Productos  as p on p.IdProductos = dv.IdProductos
group by dv.IdProductos, p.Nombre_Producto
order by count(2) desc
go



select * from Detalle_venta
select * from Venta
select * from Registro
select * from Productos
select * from Usuario
go

delete from Venta where IdVenta = 2

