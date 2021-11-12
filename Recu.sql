use master 
go

create database Filmaffinity

go 

use Filmaffinity

create table Usuarios
(
	IdUsuario int identity,
	Usuario varchar(20),
	Password varbinary(20), -- Utilizamos la longitud necesaria según el algoritmo HASH utilizado
	NombreCompleto varchar(50),
	Localidad varchar(50),
	Pais varchar(30),
	PeliculasPuntuadas int, 
	PeliculasValoradas int,
	constraint PK_Usuarios primary key (IdUsuario)
)

go

create table Peliculas
(
	Idpelicula int identity,
	Titulo varchar(50),
	Sinopsis varchar(MAX),
	Puntos decimal(3,1), 
	TotalVotos int,  
	TotalCriticas int,  
	constraint PK_Peliculas primary key (Idpelicula)
)

go

create table Criticas
(
	IdUsuario int,
	IdPelicula int,
	Critica varchar(MAX),
	Puntuacion decimal(3,1), 
	Fecha date,
	constraint PK_Criticas primary key (IdUsuario, IdPelicula),
	constraint FK_Criticas_Usuario foreign key (IdUsuario) references Usuarios,
	constraint FK_Criticas_Peliculas foreign key (IdPelicula) references Peliculas
)

go

-- Datos de prueba

-- Guardamos el password cifrado, la N delante del password hace que se guarde correctamente el tipo UNICODE 
Insert into Usuarios values ('AntonLR', HASHBYTES('SHA1',N'ABC123'),'Antonio López Ruíz','Málaga','España',0,0)
Insert into Usuarios values ('AnaGar', HASHBYTES('SHA1',N'123456'),'Ana García Soler','Granada','España',0,0)
Insert into Usuarios values ('JulPG', HASHBYTES('SHA1',N'password'),'Julian Pérez García','Granada','España',0,0)

-- select * from Usuarios

insert into Peliculas values ('La llegada','Cuando naves extraterrestres empiezan a llegar...',0,0,0)
insert into Peliculas values ('Parásitos','Tanto Gi Taek como su familia están sin trabajo...',0,0,0)
insert into Peliculas values ('Joker','Arthur Fleck (Phoenix) vive en Gotham con su madre...',0,0,0)

-- select * from Peliculas


create procedure peliculitas
	
	
	@IdUsuario int,
	@Idpelicula int,
	@Critica varchar(MAX),
	@Puntuacion decimal(3,1)


as
declare @PuntuacionMedia decimal (3,1)
begin
BEGIN TRY
BEGIN TRAN


INSERT INTO Criticas VALUES (@IdUsuario , @IdPelicula , @Critica , @Puntuacion , getdate())



if @Puntuacion is NOT NULL
 begin
   select @PuntuacionMedia= AVG(Puntuacion) from Criticas where IdPelicula=@IdPelicula
   update Peliculas set TotalVotos = TotalVotos + 1, puntos=@PuntuacionMedia where Idpelicula=@IdPelicula
   update Usuarios set PeliculasPuntuadas = PeliculasPuntuadas + 1 where IdUsuario=@IdUsuario
  end
if @Critica is NOT NULL 
begin
	update Peliculas set TotalCriticas=TotalCriticas + 1 where IdPelicula=@IdPelicula
	update Usuarios set PeliculasValoradas=PeliculasValoradas + 1 where IdUsuario=@IdUsuario
	end
	commit tran

END TRY
	BEGIN CATCH
PRINT 'Laura apruébame, te lo imploro'
rollback tran
	END CATCH
end

exec peliculitas 3,3,'critica',5.5



create TRIGGER Criticando On Criticas for insert 
as
begin

declare @IdUsuario int, @IdPelicula int,  @Critica varchar(MAX), @Puntuacion decimal(3,1), @Puntuacionmedia decimal(3,1)
select @IdUsuario=IdUsuario, @IdPelicula=IdPelicula,  @Critica=Critica , @Puntuacion=Puntuacion from inserted

if @Puntuacion is NOT NULL
 begin
   select @PuntuacionMedia= AVG(Puntuacion) from Criticas where IdPelicula=@IdPelicula
   update Peliculas set TotalVotos = TotalVotos + 1, puntos=@PuntuacionMedia where IdPelicula=IdPelicula
   update Usuarios set PeliculasPuntuadas = PeliculasPuntuadas + 1 where IdUsuario=@IdUsuario

if @Critica is NOT NULL 
	update Peliculas set TotalCriticas=TotalCriticas + 1 where IdPelicula=@IdPelicula
	update Usuarios set PeliculasValoradas=PeliculasValoradas + 1 where IdUsuario=@IdUsuario
end
end