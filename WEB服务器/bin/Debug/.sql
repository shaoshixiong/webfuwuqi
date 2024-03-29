USE [master]
GO
/****** Object:  Database [HardwareOnline]    Script Date: 2013/3/19 11:54:57 ******/
CREATE DATABASE [HardwareOnline]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'HardwareOnline', FILENAME = N'E:\备份\HardwareOnline.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'HardwareOnline_log', FILENAME = N'E:\备份\HardwareOnline_log.ldf' , SIZE = 2560KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [HardwareOnline] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [HardwareOnline].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [HardwareOnline] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [HardwareOnline] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [HardwareOnline] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [HardwareOnline] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [HardwareOnline] SET ARITHABORT OFF 
GO
ALTER DATABASE [HardwareOnline] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [HardwareOnline] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [HardwareOnline] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [HardwareOnline] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [HardwareOnline] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [HardwareOnline] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [HardwareOnline] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [HardwareOnline] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [HardwareOnline] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [HardwareOnline] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [HardwareOnline] SET  DISABLE_BROKER 
GO
ALTER DATABASE [HardwareOnline] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [HardwareOnline] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [HardwareOnline] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [HardwareOnline] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [HardwareOnline] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [HardwareOnline] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [HardwareOnline] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [HardwareOnline] SET RECOVERY FULL 
GO
ALTER DATABASE [HardwareOnline] SET  MULTI_USER 
GO
ALTER DATABASE [HardwareOnline] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [HardwareOnline] SET DB_CHAINING OFF 
GO
ALTER DATABASE [HardwareOnline] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [HardwareOnline] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'HardwareOnline', N'ON'
GO
USE [HardwareOnline]
GO
/****** Object:  StoredProcedure [dbo].[GetNumber]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--产生单号
CREATE proc [dbo].[GetNumber]
@No varchar(14) output
as
 IF EXISTS(select max(accountNumber) from account)
	begin
	declare @MaxDanhao varchar(14)
		select @MaxDanhao=max(accountNumber) from account
		set @No='DH'+ convert(varchar(8),getdate(),112)+right('0000'+convert(varchar(20),right( @MaxDanhao,4)+1),4)
	end
 else 
	begin
		set @No='DH'+convert(varchar(8),getdate(),112)+'0001'
	end
	
GO
/****** Object:  StoredProcedure [dbo].[HardwarePage]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[HardwarePage]
@pageSize int,--页大小
@pageIndex int,--页索引
@tableName varchar(20),--表名
@returnField varchar(500),--返回字段
@orderField varchar(20),--排序字段
@orderType varchar(10),--排序类型
@strWhere varchar(1000),--查询条件
@tolPage int output,--总页数
@tolRecord int output--总记录数
as
declare @mysql nvarchar(500)
if(@strWhere='')
	set @mysql='select @sql_tolRecord=count(*) from '+@tableName
else
	set @mysql='select @sql_tolRecord=count(*) from '+@tableName+' where '+@strWhere
exec sp_executesql @mysql,N'@sql_tolRecord int output',@tolRecord output
set @tolPage=ceiling(@tolRecord*1.0/@pageSize)

declare @sql varchar(1000)
if(@strWhere='')
 begin
	set @sql='select top '+convert(varchar(10),@pageSize)+@returnField
	+' from '+@tableName+' where '+@orderField+' not in(select top '
	+convert(varchar(10),(@pageIndex-1)*@pageSize)+' '+@orderField
	+' from '+@tableName+' order by '+@orderField+' '+@orderType+')'
	+' order by '+@orderField+' '+@orderType
 end
else
 begin
	set @sql='select top '+convert(varchar(10),@pageSize)+@returnField
	+' from '+@tableName+' where ('+@orderField+' not in(select top '
	+convert(varchar(10),(@pageIndex-1)*@pageSize)+' '+@orderField
	+' from '+@tableName+' where '+@strWhere+' order by '+@orderField+' '+@orderType+')) and '
	+@strWhere+' order by '+@orderField+' '+@orderType
 end
exec(@sql)--执行sql语句,记得打括号



GO
/****** Object:  Table [dbo].[account]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[account](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NULL,
	[sellerId] [int] NULL,
	[accountNumber] [varchar](50) NULL,
	[accountTime] [datetime] NULL,
	[tolMoney] [money] NULL,
 CONSTRAINT [PK_account] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[accountDetail]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[accountDetail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[productId] [int] NOT NULL,
	[accountNumber] [varchar](50) NOT NULL,
	[count] [int] NULL,
	[Money] [money] NULL,
 CONSTRAINT [PK_accountDetail] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AdManage]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AdManage](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[URLAddress] [varchar](200) NULL,
	[UploadAdUrl] [varchar](200) NULL,
	[RecomPosition] [varchar](100) NOT NULL,
 CONSTRAINT [PK_ADMANAGE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AreaManage]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AreaManage](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ParentId] [int] NULL,
	[AreaNames] [varchar](100) NOT NULL,
	[Position] [int] NULL,
 CONSTRAINT [PK_AreaManage] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[commonOrder]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[commonOrder](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userId] [int] NOT NULL,
	[sellId] [int] NOT NULL,
	[OrderNumber] [varchar](50) NOT NULL,
	[OrderTime] [datetime] NOT NULL,
	[tolMoney] [money] NULL,
 CONSTRAINT [PK_commonOrder] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[commonOrderDetail]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[commonOrderDetail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[productId] [int] NOT NULL,
	[commonOrderId] [int] NOT NULL,
	[count] [int] NOT NULL,
	[Money] [money] NULL,
 CONSTRAINT [PK_commonOrderDetail] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FriendshipLink]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FriendshipLink](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ImageUrl] [varchar](100) NULL,
	[URL] [varchar](200) NULL,
 CONSTRAINT [PK_FRIENDSHIPLINK] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MessageType]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MessageType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_MESSAGETYPE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NetworkConfig]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NetworkConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SiteTitle] [varchar](100) NOT NULL,
	[SiteKeyWord] [varchar](500) NOT NULL,
	[SiteRecommend] [varchar](500) NULL,
 CONSTRAINT [PK_NETWORKCONFIG] PRIMARY KEY CLUSTERED 
(
	[Id] ASC,
	[SiteTitle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NewsClass]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NewsClass](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SeqNum] [int] NULL,
	[ClassName] [varchar](200) NULL,
 CONSTRAINT [PK_NEWSCLASS] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NewsManage]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NewsManage](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TypeId] [int] NOT NULL,
	[Title] [varchar](200) NOT NULL,
	[Source] [varchar](200) NULL,
	[Author] [varchar](100) NULL,
	[NewsImageUrl] [varchar](200) NULL,
	[Content] [text] NULL,
	[NewsDate] [datetime] NOT NULL,
	[clickCount] [int] NULL,
 CONSTRAINT [PK_NEWSMANAGE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Product]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Product](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserDetailId] [int] NULL,
	[Title] [varchar](200) NOT NULL,
	[TypeId] [int] NOT NULL,
	[MessageTypeId] [int] NULL,
	[PublishTime] [datetime] NOT NULL,
	[LinkMan] [varchar](50) NULL,
	[ProductTypeId] [int] NOT NULL,
	[ProductImageUrl] [varchar](200) NULL,
	[ProductCount] [int] NULL,
	[PackExplain] [varchar](200) NULL,
	[PriceExplain] [varchar](200) NULL,
	[ProductSpec] [varchar](200) NULL,
	[IndateId] [varchar](100) NULL,
	[DetailIntroduce] [varchar](500) NULL,
	[Tel] [varchar](100) NULL,
	[Phone] [varchar](100) NULL,
	[Fax] [varchar](100) NULL,
	[Email] [varchar](100) NULL,
	[URL] [varchar](200) NULL,
	[DetailAddress] [varchar](200) NULL,
	[isFlag] [varchar](6) NULL,
 CONSTRAINT [PK_PRODUCT] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProductType]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProductType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [varchar](100) NOT NULL,
	[ParentId] [int] NOT NULL,
 CONSTRAINT [PK_PRODUCTTYPE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ShowManage]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShowManage](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TypeId] [int] NOT NULL,
	[Title] [varchar](200) NOT NULL,
	[Source] [varchar](200) NULL,
	[Author] [varchar](100) NULL,
	[NewsImageUrl] [varchar](200) NULL,
	[Content] [text] NULL,
	[NewsDate] [datetime] NOT NULL,
	[clickCount] [int] NULL,
 CONSTRAINT [PK_SHOWMANAGE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ShowType]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShowType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ShowName] [varchar](200) NOT NULL,
 CONSTRAINT [PK_SHOWTYPE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SitesCopyRight]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SitesCopyRight](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Content] [text] NOT NULL,
 CONSTRAINT [PK_SITESCOPYRIGHT] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserDetails]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserDetails](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[Dep] [varchar](50) NULL,
	[Post] [varchar](50) NULL,
	[Tel] [varchar](50) NULL,
	[Fax] [varchar](50) NULL,
	[Phone] [varchar](50) NULL,
	[EnterPriseAddress] [varchar](100) NULL,
	[PostCode] [varchar](50) NULL,
	[QQNumber] [varchar](50) NULL,
	[EnterpriseSite] [varchar](50) NULL,
	[EnterpriseName] [varchar](500) NULL,
	[keyword] [varchar](300) NULL,
	[EnterpriseMark] [varchar](200) NULL,
	[MianFx] [varchar](50) NULL,
	[SellProduct] [varchar](50) NULL,
	[ProcProduct] [varchar](50) NULL,
	[ManageMode] [varchar](100) NULL,
	[Count] [varchar](50) NULL,
	[EnterpriseType] [varchar](50) NULL,
	[EnterpriseJianjie] [varchar](500) NULL,
	[EnterpriseImageUrl] [varchar](50) NULL,
 CONSTRAINT [PK_UserDetails] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Users]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Users](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varbinary](50) NULL,
	[UserName] [varchar](100) NOT NULL,
	[PassWord] [varchar](100) NOT NULL,
	[Sex] [varchar](2) NULL,
	[Problem] [varchar](200) NULL,
	[Answer] [varchar](200) NULL,
	[Email] [varchar](200) NULL,
	[UserTypeId] [int] NULL,
	[RegTime] [datetime] NULL,
	[TradeTypeId] [int] NULL,
	[AreaId] [int] NULL,
 CONSTRAINT [PK_USERS] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserType]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserTypeName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_USERTYPE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[wjps_Order]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[wjps_Order](
	[id] [int] NOT NULL,
	[userId] [int] NOT NULL,
	[OrderNumber] [varchar](50) NOT NULL,
	[OrderTime] [datetime] NULL,
	[tolMoney] [money] NULL,
 CONSTRAINT [PK_wjps_Order] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[wjps_orderDetail]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wjps_orderDetail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[wjpsOrderId] [int] NOT NULL,
	[count] [int] NULL,
	[Money] [money] NULL,
 CONSTRAINT [PK_wjps_orderDetail] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[wjpsManage]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[wjpsManage](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userId] [int] NOT NULL,
	[typeId] [int] NOT NULL,
	[areaid] [int] NOT NULL,
	[messageTypeId] [int] NOT NULL,
	[publishTime] [datetime] NULL,
	[title] [varchar](50) NULL,
	[imageUrl] [varchar](500) NULL,
	[count] [int] NULL,
	[package] [varchar](500) NULL,
	[price] [money] NULL,
	[Norms] [varchar](50) NULL,
	[Indate] [varchar](50) NULL,
	[DetailRecommend] [varchar](500) NULL,
	[LinkMan] [varchar](50) NULL,
	[Tel] [varchar](50) NULL,
	[Phone] [varchar](50) NULL,
	[Fax] [varchar](50) NULL,
	[Email] [varchar](50) NULL,
	[Site] [varchar](300) NULL,
	[DetailAdress] [varchar](100) NULL,
	[isFlag] [varchar](50) NULL,
 CONSTRAINT [PK_wjpsManage] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[wjpsType]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[wjpsType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ClassName] [varchar](50) NULL,
	[ParentId] [int] NULL,
 CONSTRAINT [PK_wjpsType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ZhaoPin]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ZhaoPin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Company] [varchar](200) NULL,
	[Post] [varchar](200) NULL,
	[AreaId] [int] NULL,
	[Sex] [varchar](10) NULL,
	[PeopleCount] [int] NULL,
	[Education] [varchar](100) NULL,
	[UserDate] [varchar](100) NULL,
	[MonthPay] [varchar](100) NULL,
	[TempJob] [varchar](100) NULL,
	[SpecificAsk] [text] NULL,
	[Address] [varchar](100) NULL,
	[LinkMan] [varchar](100) NULL,
	[Tel] [varchar](100) NULL,
	[Phone] [varchar](100) NULL,
	[Fix] [varchar](100) NULL,
	[Email] [varchar](100) NULL,
	[SiteAddress] [varchar](200) NULL,
	[Date] [datetime] NULL,
 CONSTRAINT [PK_ZHAOPIN] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[News_type]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[News_type]
as
select n.Id,ClassName, TypeId, Title, Source, Author, NewsImageUrl, Content, NewsDate from
NewsManage n inner join NewsClass c on c.Id=n.TypeId

GO
/****** Object:  View [dbo].[Product_Number]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Product_Number]
as
select count(0) Number,MessageTypeId from Product group by MessageTypeId
GO
/****** Object:  View [dbo].[Product_Pt_Mt]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[Product_Pt_Mt]
as
select p.Id, Title, TypeName, PublishTime, LinkMan, ProductName, ProductImageUrl, ProductCount, PackExplain, PriceExplain, ProductSpec, IndateId, DetailIntroduce, Tel, Phone, Fax, Email, URL, DetailAddress from Product p inner join ProductType t on p.ProductTypeId=t.Id inner join MessageType m on m.id=p.TypeId
GO
/****** Object:  View [dbo].[Users_UsersDetail]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Users_UsersDetail]
as
 select d.id,[RegTime],EnterpriseImageUrl,UserName, Dep, Post, Tel, Fax, Phone, EnterPriseAddress, PostCode, QQNumber, EnterpriseSite, EnterpriseName, keyword, EnterpriseMark, MianFx, SellProduct, ProcProduct, ManageMode, [Count], EnterpriseType, EnterpriseJianjie from Users u inner join UserDetails d on u.UserId=d.UserId



GO
/****** Object:  View [dbo].[Users_UserType]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Users_UserType]
as
 select UserId,UserTypeId, UserName, PassWord, Sex, Problem, Answer, Email, UserTypeName from Users u inner join UserType t on u.UserTypeId=t.Id

GO
/****** Object:  View [dbo].[view_AreaManage]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[view_AreaManage]
as
select * from AreaManage union select Id=0, ParentId='-1', AreaNames='全部',Position='0'

GO
/****** Object:  View [dbo].[view_MessageType]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[view_MessageType]
as
select * from MessageType union select Id=0, TypeName='显示全部'

GO
/****** Object:  View [dbo].[view_News_Man]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[view_News_Man]
as

select  ClassName,m.Id, TypeId, Title, Source, Author, NewsImageUrl, Content, NewsDate from NewsManage m inner join NewsClass n on n.Id=m.TypeId
GO
/****** Object:  View [dbo].[view_NewsClass]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[view_NewsClass]
as
select * from NewsClass union select  Id='-1',SeqNum='0',ClassName='显示全部'

GO
/****** Object:  View [dbo].[view_Pro_Mess]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[view_Pro_Mess]
as
 select p.Id, isFlag,Title,TypeId, TypeName, PublishTime, LinkMan, ProductTypeId, ProductImageUrl, ProductCount, PackExplain, PriceExplain, ProductSpec, IndateId, DetailIntroduce, Tel, Phone, Fax, Email, URL, DetailAddress
 from Product p inner join MessageType m on p.TypeId=m.Id



GO
/****** Object:  View [dbo].[view_Pro_Type]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[view_Pro_Type]
as
	select p.Id,Title,URL,TypeName from Product p inner join MessageType m on p.TypeId=m.Id


GO
/****** Object:  View [dbo].[view_pro_User]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[view_pro_User]
as
select  p.id pid,d.[id],[EnterpriseName],UserDetailId, Title, TypeId, MessageTypeId, PublishTime, LinkMan, ProductTypeId, ProductImageUrl, ProductCount, PackExplain, PriceExplain, ProductSpec, IndateId, DetailIntroduce, p.Tel, p.Phone, [EnterPriseAddress],p.Fax, Email, URL, DetailAddress from Product p inner join UserDetails d on p.UserDetailId=d.id



GO
/****** Object:  View [dbo].[view_Product_MessageType]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[view_Product_MessageType]
as
	select Title,URL,TypeName from Product p inner join MessageType m on p.TypeId=m.Id
GO
/****** Object:  View [dbo].[view_ProductType]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[view_ProductType]
as
select * from ProductType union select Id=0, ProductName='全部', ParentId='-1'
GO
/****** Object:  View [dbo].[view_Show_Man]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[view_Show_Man]
as

select  ShowName,m.Id , TypeId, Title, Source, Author, NewsImageUrl, Content, NewsDate from ShowManage m inner join ShowType n on n.Id=m.TypeId
GO
/****** Object:  View [dbo].[view_UDeteail_Pro]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[view_UDeteail_Pro]
as
select p.id,[URL],[Title],TypeName,UserDetailId from UserDetails d inner join Product p on d.id=p.UserDetailId inner join MessageType t on t.id=p.MessageTypeId 

GO
/****** Object:  View [dbo].[view_User_UserDetails]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[view_User_UserDetails]
as
	select UserName from Users u inner join UserDetails d on u.UserId = d.UserId
GO
/****** Object:  View [dbo].[view_wjpsType]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[view_wjpsType]
as
select * from wjpsType union select Id=0, ClassName='全部', ParentId='-1'

GO
/****** Object:  View [dbo].[view_wManage_Mess]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[view_wManage_Mess]
as
 select m.id,isFlag,TypeName,userId, typeId, areaid, messageTypeId, publishTime, title, imageUrl, [count], package, price, Norms, Indate, DetailRecommend, LinkMan, Tel, Phone, Fax, Email, [Site], DetailAdress from wjpsManage m inner join MessageType t on m.messageTypeId=t.id




GO
/****** Object:  View [dbo].[view_wManage_wType]    Script Date: 2013/3/19 11:54:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[view_wManage_wType]
as
 select m.id,ClassName,userId, typeId, areaid, messageTypeId, publishTime, title, imageUrl, [count], package, price, Norms, Indate, DetailRecommend, LinkMan, Tel, Phone, Fax, Email, [Site], DetailAdress from wjpsManage m inner join wjpsType t on m.typeId=t.id


GO
ALTER TABLE [dbo].[account]  WITH CHECK ADD  CONSTRAINT [FK_account_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[account] CHECK CONSTRAINT [FK_account_Users]
GO
ALTER TABLE [dbo].[account]  WITH CHECK ADD  CONSTRAINT [FK_account_Users1] FOREIGN KEY([sellerId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[account] CHECK CONSTRAINT [FK_account_Users1]
GO
ALTER TABLE [dbo].[accountDetail]  WITH CHECK ADD  CONSTRAINT [FK_accountDetail_Product] FOREIGN KEY([productId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[accountDetail] CHECK CONSTRAINT [FK_accountDetail_Product]
GO
ALTER TABLE [dbo].[commonOrder]  WITH CHECK ADD  CONSTRAINT [FK_commonOrder_Users] FOREIGN KEY([userId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[commonOrder] CHECK CONSTRAINT [FK_commonOrder_Users]
GO
ALTER TABLE [dbo].[commonOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_commonOrderDetail_commonOrderDetail] FOREIGN KEY([commonOrderId])
REFERENCES [dbo].[commonOrder] ([id])
GO
ALTER TABLE [dbo].[commonOrderDetail] CHECK CONSTRAINT [FK_commonOrderDetail_commonOrderDetail]
GO
ALTER TABLE [dbo].[commonOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_commonOrderDetail_Product] FOREIGN KEY([productId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[commonOrderDetail] CHECK CONSTRAINT [FK_commonOrderDetail_Product]
GO
ALTER TABLE [dbo].[NewsManage]  WITH CHECK ADD  CONSTRAINT [FK_NEWSMANA_REFERENCE_NEWSCLAS] FOREIGN KEY([TypeId])
REFERENCES [dbo].[NewsClass] ([Id])
GO
ALTER TABLE [dbo].[NewsManage] CHECK CONSTRAINT [FK_NEWSMANA_REFERENCE_NEWSCLAS]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_MessageType] FOREIGN KEY([MessageTypeId])
REFERENCES [dbo].[MessageType] ([Id])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_MessageType]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_PRODUCT_REFERENCE_PRODUCTT] FOREIGN KEY([ProductTypeId])
REFERENCES [dbo].[ProductType] ([Id])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_PRODUCT_REFERENCE_PRODUCTT]
GO
ALTER TABLE [dbo].[ShowManage]  WITH CHECK ADD  CONSTRAINT [FK_SHOWMANA_REFERENCE_SHOWTYPE] FOREIGN KEY([TypeId])
REFERENCES [dbo].[ShowType] ([Id])
GO
ALTER TABLE [dbo].[ShowManage] CHECK CONSTRAINT [FK_SHOWMANA_REFERENCE_SHOWTYPE]
GO
ALTER TABLE [dbo].[UserDetails]  WITH CHECK ADD  CONSTRAINT [FK_UserDetails_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserDetails] CHECK CONSTRAINT [FK_UserDetails_Users]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_AreaManage] FOREIGN KEY([AreaId])
REFERENCES [dbo].[AreaManage] ([id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_AreaManage]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_ProductType] FOREIGN KEY([TradeTypeId])
REFERENCES [dbo].[ProductType] ([Id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_ProductType]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_USERS_REFERENCE_USERTYPE] FOREIGN KEY([UserTypeId])
REFERENCES [dbo].[UserType] ([Id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_USERS_REFERENCE_USERTYPE]
GO
ALTER TABLE [dbo].[wjps_Order]  WITH CHECK ADD  CONSTRAINT [FK_wjps_Order_Users] FOREIGN KEY([userId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[wjps_Order] CHECK CONSTRAINT [FK_wjps_Order_Users]
GO
ALTER TABLE [dbo].[wjps_orderDetail]  WITH CHECK ADD  CONSTRAINT [FK_wjps_orderDetail_wjps_Order] FOREIGN KEY([wjpsOrderId])
REFERENCES [dbo].[wjps_Order] ([id])
GO
ALTER TABLE [dbo].[wjps_orderDetail] CHECK CONSTRAINT [FK_wjps_orderDetail_wjps_Order]
GO
ALTER TABLE [dbo].[wjps_orderDetail]  WITH CHECK ADD  CONSTRAINT [FK_wjps_orderDetail_wjps_orderDetail] FOREIGN KEY([ProductId])
REFERENCES [dbo].[wjpsManage] ([id])
GO
ALTER TABLE [dbo].[wjps_orderDetail] CHECK CONSTRAINT [FK_wjps_orderDetail_wjps_orderDetail]
GO
ALTER TABLE [dbo].[wjpsManage]  WITH CHECK ADD  CONSTRAINT [FK_wjpsManage_AreaManage] FOREIGN KEY([areaid])
REFERENCES [dbo].[AreaManage] ([id])
GO
ALTER TABLE [dbo].[wjpsManage] CHECK CONSTRAINT [FK_wjpsManage_AreaManage]
GO
ALTER TABLE [dbo].[wjpsManage]  WITH CHECK ADD  CONSTRAINT [FK_wjpsManage_MessageType] FOREIGN KEY([messageTypeId])
REFERENCES [dbo].[MessageType] ([Id])
GO
ALTER TABLE [dbo].[wjpsManage] CHECK CONSTRAINT [FK_wjpsManage_MessageType]
GO
ALTER TABLE [dbo].[wjpsManage]  WITH CHECK ADD  CONSTRAINT [FK_wjpsManage_Users] FOREIGN KEY([userId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[wjpsManage] CHECK CONSTRAINT [FK_wjpsManage_Users]
GO
ALTER TABLE [dbo].[wjpsManage]  WITH CHECK ADD  CONSTRAINT [FK_wjpsManage_wjpsType] FOREIGN KEY([typeId])
REFERENCES [dbo].[wjpsType] ([id])
GO
ALTER TABLE [dbo].[wjpsManage] CHECK CONSTRAINT [FK_wjpsManage_wjpsType]
GO
USE [master]
GO
ALTER DATABASE [HardwareOnline] SET  READ_WRITE 
GO
