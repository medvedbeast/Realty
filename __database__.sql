-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Хост: localhost:3306
-- Время создания: Июн 14 2018 г., 10:27
-- Версия сервера: 5.6.39
-- Версия PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `applingi_topreal`
--

DELIMITER $$
--
-- Процедуры
--
CREATE DEFINER=`applingi`@`localhost` PROCEDURE `AddOffer` (IN `title` VARCHAR(2048) CHARSET utf8, IN `description` VARCHAR(15360) CHARSET utf8, IN `location` VARCHAR(2048) CHARSET utf8, IN `video` VARCHAR(2048) CHARSET utf8, IN `category` INT, IN `owner` INT, IN `characteristics` VARCHAR(4096) CHARSET utf8)  NO SQL
begin
	insert into offers (`title`, `description`, `location`, `video`, `category_id`, `owner_id`) values (title, description, location, video, category, owner);
	select max(o.id) into @id from offers as o;
	select @id;
	if length(characteristics) > 0 then
		set @query = "insert into offerCharacteristics (value, offer_id, characteristic_id) values";
		set @count = length(characteristics) - length(replace(characteristics, "][", " "));
		set @count = @count + 1;
        set @i = 0;
        set @start = 2;
        while @i < @count do
            set @array = substring_index(characteristics, "]", @i + 1);
            set @array = substring(@array, @start, length(@array) - @start);
            set @start = length(@array) + @start + 3;
            set @characteristicId = substring_index(@array, ";", 1);
            set @l1 = length(@characteristicId);
            set @l2 = length(substring_index(@array, ";", 2)) - (@l1 + 1);
            set @value = substring(@array, @l1 + 2, @l2);
            set @i = @i + 1;
			set @query = concat(@query, " ('", @value, "', '", @id, "', '", @characteristicId, "'),");
        end while;
		set @query = substring(@query, 1, length(@query) - 1);
	end if;
	prepare query from @query;
	execute query;
	deallocate prepare query;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `AddPost` (IN `title` VARCHAR(1024) CHARSET utf8, IN `content` VARCHAR(16384) CHARSET utf8, IN `author_id` INT, IN `image` VARCHAR(1024) CHARSET utf8)  NO SQL
begin
	insert into posts (`title`, `content`, `author_id`, `date`, `image`) values (title, content, author_id, now(), image);
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetCategory` (IN `id` INT, IN `parent_category_id` INT)  NO SQL
begin
	if id > 0 then
		select c.id, c.title, c.category_group_id, c.parent_category_id from categories as c where c.id = id;
	else
		select c.id, c.title, c.category_group_id, c.parent_category_id from categories as c where c.parent_category_id = parent_category_id;
	end if;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetCategoryChildren` (IN `root` INT, OUT `results` VARCHAR(1024))  NO SQL
begin
	declare done int default false;
	declare id int;
	declare offerId int;
	declare c cursor for select o.category_id, o.id from offers as o;
	declare continue handler for not found set done = true;
	open c;
	set @r = "o.id in (";
	searchLoop : loop
		fetch c into id, offerId;
		if done then
			leave searchLoop;
		end if;
		set @flag = true;
		set @c = id;
		set @result = -1;
		while @flag do
			select c.parent_category_id from categories as c where c.id = @c into @tmp;
			if @tmp = root then
				set @flag = false;
				set @result = offerId;
			else
				if @tmp = 0 then
					set @flag = false;
				end if;
				set @c = @tmp;
			end if;
		end while;
		if @result != -1 then
			set @r = concat(@r, @result, ", ");
		end if;
	end loop;
	set @r = substring(@r, 1, length(@r) - 2);
	set @r = concat(@r, ")");
	select @r into results;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetCategoryGroup` (IN `id` INT)  NO SQL
    COMMENT 'Get all categories'
begin
	select cg.id, cg.title, cg.precision from categoryGroups as cg where cg.id = id;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetCharacteristic` (IN `id` INT, IN `categoryId` INT)  NO SQL
begin
	if id > 0 then
		select ch.id, ch.title, ch.unit_id, ch.characteristic_type_id, ch.characteristic_group_id, ch.parent_characteristic_id from characteristics as ch where ch.id = id;
	else
		select ch.id, ch.title, ch.unit_id, ch.characteristic_type_id, ch.characteristic_group_id, ch.parent_characteristic_id from characteristics as ch, categories as c where c.id = categoryId and c.characteristic_group_id = ch.characteristic_group_id;
	end if;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetImage` (IN `imageId` INT)  NO SQL
begin
	if imageId < 1 then
		select 0 as id, 0 as is_preview, 0 as offer_id, path from images where length(path) > 0
		union
		select 0 as id, 0 as is_preview, 0 as offer_id, image from posts where length(image) > 0
		union
		select 0 as id, 0 as is_preview, 0 as offer_id, photo from users where length(photo) > 0;
	else
		select id, is_preview, offer_id, path from images where id = imageId;
	end if;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetOffer` (IN `id` INT, IN `ownerId` INT)  NO SQL
begin
	if ownerId > 0 then
		select o.id, o.title, o.description, o.location, o.video, o.category_id, o.owner_id from offers as o where o.owner_id = ownerId;
	else
		select o.id, o.title, o.description, o.location, o.video, o.category_id, o.owner_id from offers as o where o.id = id;
	end if;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetOfferCharacteristics` (IN `offerId` INT)  NO SQL
begin
	select oc.id, oc.value, oc.offer_id, oc.characteristic_id from offerCharacteristics as oc where oc.offer_id = offerId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetOfferCount` (IN `categoryId` INT, IN `characteristics` VARCHAR(8192), IN `keywords` VARCHAR(4096))  NO SQL
begin
	set @query = "select count(*)";
	if length(characteristics) > 0 then
		set @query = concat(@query, " from offers as o, offerCharacteristics as oc where oc.offer_id = o.id and o.category_id = ", categoryId);
	else
		if categoryId > 0 then
			select count(*) into @childCategories from categories where parent_category_id = categoryId;
			if @childCategories < 1 then
				set @query = concat(@query, " from offers as o where o.category_id = ", categoryId);
			else
				call GetCategoryChildren(categoryId, @results);
				set @query = concat(@query, " from offers as o where ", @results);
			end if;
		else
			set @query = concat(@query, " from offers as o where");
		end if;
	end if;
	if length(characteristics) > 0 then
		set @count = length(characteristics) - length(replace(characteristics, "][", " "));
		set @count = @count + 1;
        set @i = 0;
        set @start = 2;
        set @previousId = 0;
        set @previousPrecision = "";
        while @i < @count do
            set @array = substring_index(characteristics, "]", @i + 1);
            set @array = substring(@array, @start, length(@array) - @start);
            set @start = length(@array) + @start + 3;
            set @id = substring_index(@array, ";", 1);
            set @l1 = length(@id);
            set @l2 = length(substring_index(@array, ";", 2)) - (@l1 + 1);
            set @value = substring(@array, @l1 + 2, @l2);
            set @l3 = length(substring_index(@array, ";", 3)) - (@l1 + @l2 + 2);
            set @precision = substring(@array, (@l1 + @l2) + 3, @l3);
            if @precision like "max" then
				if @previousId like @id and @previousPrecision like "min" then
					set @query = concat(@query, " and ", @value);
				else
					set @query = concat(@query, " and oc.characteristic_id = ", @id, " and oc.value between 0 and ", @value);
				end if;
            else
				if @previousPrecision like "min" then
					select count(value) into @c from offerCharacteristics where characteristic_id = @id;
					if @c > 0 then
						select max(value) into @m from offerCharacteristics where characteristic_id = @id;
					else
						set @m = '100000000';
					end if;
					set @query = concat(@query, " and ", @m);
				end if;
				if @precision like "option" then
					set @query = concat(@query, " and oc.characteristic_id = ", @id, " and oc.value = ", @value);
				else
					set @query = concat(@query, " and oc.characteristic_id = ", @id, " and oc.value between ", @value);
					if @i + 1 >= @count then
						select count(value) into @c from offerCharacteristics where characteristic_id = @id;
						if @c > 0 then
							select max(value) into @m from offerCharacteristics where characteristic_id = @id;
						else
							set @m = '100000000';
						end if;
						set @query = concat(@query, " and ", @m);
					end if;
				end if;			
            end if;
            set @previousId = @id;
            set @previousPrecision = @precision;
            set @i = @i + 1;
        end while;
	end if;
	if length(keywords) > 0 then
		set @keywords = concat(keywords, " ");
		set @query = concat(@query, " and (");
		set @count = length(@keywords) - length(replace(@keywords, " ", ""));
		set @i = 0;
		set @start = 1;
		while @i < @count do
			set @word = substring_index(@keywords, " ", @i + 1);
			set @word = substring(@word from @start);
			set @start = @start + length(@word) + 1;
			set @query = concat(@query, "o.title like '%", @word, "%' or o.description like '%", @word, "%' or o.location like '%", @word, "%'");
			if @i + 1 < @count then
				set @query = concat(@query, " or ");
			end if;
			set @i = @i + 1;
		end while;
		set @query = concat(@query, ")");
	end if;
	prepare q from @query;
	execute q;
	deallocate prepare q;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetOfferImages` (IN `offerId` INT)  NO SQL
begin
	select i.id, i.is_preview, i.offer_id, i.path from images as i where i.offer_id = offerId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetOfferPreviewImage` (IN `offer_id` INT)  NO SQL
begin
	select i.id, i.is_preview, i.offer_id, i.path from images as i where i.offer_id = offer_id and i.is_preview = 1;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetOfferPreviews` (IN `categoryId` INT, IN `characteristics` VARCHAR(8192), IN `keywords` VARCHAR(4096), IN `start` INT, IN `quantity` INT, IN `ownerId` INT)  NO SQL
begin
	set @query = "select o.id, o.title, o.description, o.location";
	if length(characteristics) > 0 then
		set @query = concat(@query, " from offers as o, offerCharacteristics as oc where oc.offer_id = o.id and o.category_id = ", categoryId);
	else
		if categoryId > 0 then
			select count(*) into @childCategories from categories where parent_category_id = categoryId;
			if @childCategories < 1 then
				set @query = concat(@query, " from offers as o where o.category_id = ", categoryId);
			else
				call GetCategoryChildren(categoryId, @results);
				set @query = concat(@query, " from offers as o where ", @results);
			end if;
		else
			set @query = concat(@query, " from offers as o where");
		end if;
	end if;
	if length(characteristics) > 0 then
		set @count = length(characteristics) - length(replace(characteristics, "][", " "));
		set @count = @count + 1;
        set @i = 0;
        set @start = 2;
        set @previousId = 0;
        set @previousPrecision = "";
        while @i < @count do
            set @array = substring_index(characteristics, "]", @i + 1);
            set @array = substring(@array, @start, length(@array) - @start);
            set @start = length(@array) + @start + 3;
            set @id = substring_index(@array, ";", 1);
            set @l1 = length(@id);
            set @l2 = length(substring_index(@array, ";", 2)) - (@l1 + 1);
            set @value = substring(@array, @l1 + 2, @l2);
            set @l3 = length(substring_index(@array, ";", 3)) - (@l1 + @l2 + 2);
            set @precision = substring(@array, (@l1 + @l2) + 3, @l3);
            if @precision like "max" then
				if @previousId like @id and @previousPrecision like "min" then
					set @query = concat(@query, " and ", @value);
				else
					set @query = concat(@query, " and oc.characteristic_id = ", @id, " and oc.value between 0 and ", @value);
				end if;
            else
				if @previousPrecision like "min" then
					select count(value) into @c from offerCharacteristics where characteristic_id = @id;
					if @c > 0 then
						select max(value) into @m from offerCharacteristics where characteristic_id = @id;
					else
						set @m = '100000000';
					end if;
					set @query = concat(@query, " and ", @m);
				end if;
				if @precision like "option" then
					set @query = concat(@query, " and oc.characteristic_id = ", @id, " and oc.value = ", @value);
				else
					set @query = concat(@query, " and oc.characteristic_id = ", @id, " and oc.value between ", @value);
					if @i + 1 >= @count then
						select count(value) into @c from offerCharacteristics where characteristic_id = @id;
						if @c > 0 then
							select max(value) into @m from offerCharacteristics where characteristic_id = @id;
						else
							set @m = '100000000';
						end if;
						set @query = concat(@query, " and ", @m);
					end if;
				end if;			
            end if;
            set @previousId = @id;
            set @previousPrecision = @precision;
            set @i = @i + 1;
        end while;
	end if;
	if length(keywords) > 0 then
		set @keywords = concat(keywords, " ");
		set @query = concat(@query, " and (");
		set @count = length(@keywords) - length(replace(@keywords, " ", ""));
		set @i = 0;
		set @start = 1;
		while @i < @count do
			set @word = substring_index(@keywords, " ", @i + 1);
			set @word = substring(@word from @start);
			set @start = @start + length(@word) + 1;
			set @query = concat(@query, "o.title like '%", @word, "%' or o.description like '%", @word, "%' or o.location like '%", @word, "%'");
			if @i + 1 < @count then
				set @query = concat(@query, " or ");
			end if;
			set @i = @i + 1;
		end while;
		set @query = concat(@query, ")");
	end if;
	if ownerId > 0 then
		set @query = concat(@query, " o.owner_id = ", ownerId);
	end if;
	if quantity > 0 then
		set @query = concat(@query, " order by o.id desc");
		set @query = concat(@query, " limit ", start, ", ", quantity, ";");
	else
		set @query = concat(@query, ";");
	end if;
	prepare q from @query;
	execute q;
	deallocate prepare q;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetPaidOffers` ()  NO SQL
begin
	select o.id, o.title from offers as o, paidOffers as po where o.id = po.offer_id limit 4;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetPost` (IN `id` INT)  NO SQL
begin
	select p.views into @views from posts as p where p.id = id;
	update posts as p set p.views = (@views + 1) where p.id = id;
	select p.id, p.title, p.content, p.author_id, p.date, p.image, p.views from posts as p where p.id = id;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetPostCount` (IN `keywords` VARCHAR(4096))  NO SQL
    COMMENT 'Get post count'
begin
	set @query = "select count(p.id) from posts as p";
	if length(keywords) > 0 then
		set @keywords = concat(keywords, " ");
		set @query = concat(@query, " where ");
		set @count = length(@keywords) - length(replace(@keywords, " ", ""));
		set @i = 0;
		set @start = 1;
		while @i < @count do
			set @word = substring_index(@keywords, " ", @i + 1);
			set @word = substring(@word from @start);
			set @start = @start + length(@word) + 1;
			set @query = concat(@query, "p.title like '%", @word, "%' or p.content like '%", @word, "%'");
			if @i + 1 < @count then
				set @query = concat(@query, " or ");
			end if;
			set @i = @i + 1;
		end while;	
	end if;
	prepare q from @query;
	execute q;
	deallocate prepare q;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetPostImage` (IN `postId` INT)  NO SQL
begin
	select image from posts where id = postId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetPostPreviews` (IN `start` INT, IN `quantity` INT, IN `keywords` VARCHAR(2048), IN `ownerId` INT)  NO SQL
begin
	set @query = "select p.id, p.title, p.content, p.date, p.image from posts as p";
	if length(keywords) > 0 then
		set @keywords = concat(keywords, " ");
		set @query = concat(@query, " where ");
		set @count = length(@keywords) - length(replace(@keywords, " ", ""));
		set @i = 0;
		set @start = 1;
		while @i < @count do
			set @word = substring_index(@keywords, " ", @i + 1);
			set @word = substring(@word from @start);
			set @start = @start + length(@word) + 1;
			set @query = concat(@query, "p.title like '%", @word, "%' or p.content like '%", @word, "%'");
			if @i + 1 < @count then
				set @query = concat(@query, " or ");
			end if;
			set @i = @i + 1;
		end while;
	end if;
	if start >= 0 and quantity > 0 then
		set @query = concat(@query, " order by p.id desc");
		set @query = concat(@query, " limit ", start, ", ", quantity, ";");
	end if;
	if ownerId > 0 then
		set @query = concat(@query, " where author_id = ", ownerId);
	end if;
	prepare q from @query;
	execute q;
	deallocate prepare q;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetPriceCharacteristics` (IN `offerId` INT)  NO SQL
begin
	select c.title, oc.value, u.code from offerCharacteristics as oc, characteristics as c, units as u where oc.characteristic_id = c.id and c.unit_id = u.id and oc.offer_id = offerId and u.unitGroup = 1;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetUnit` (IN `id` INT, IN `groupId` INT)  NO SQL
begin
	if groupId < 1 then
		select u.id, u.title, u.symbol, u.code, u.unitGroup from units as u where u.id = id;
	else
		select u.id, u.title, u.symbol, u.code, u.unitGroup from units as u where u.unitGroup = groupId;
	end if;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetUser` (IN `id` INT, IN `access` INT)  NO SQL
begin
	if access < 1 then
		select u.id, u.nickname, u.password, u.firstName, u.lastName, u.email, u.telephone, u.site, u.position, u.experience, u.country, u.userGroupId, u.dateOfBirth, u.dateOfRegistration, u.about, u.photo from users as u where u.id = id;
	else
		select u.id, u.nickname, u.password, u.firstName, u.lastName, u.email, u.telephone, u.site, u.position, u.experience, u.country, u.userGroupId, u.dateOfBirth, u.dateOfRegistration, u.about, u.photo from users as u, userGroups as ug where u.userGroupId = ug.id and ug.access = access;
	end if;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `GetUserImage` (IN `userId` INT)  NO SQL
begin
	select photo from users where `id` = userId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `LinkOfferImage` (IN `image` VARCHAR(4096), IN `id` INT)  NO SQL
begin
	select count(id) into @count from images as i where i.offer_id = id and i.is_preview = 1;
	if @count > 0 then
		insert into images (is_preview, offer_id, path) values (0, id, image);
	else
		insert into images (is_preview, offer_id, path) values (1, id, image);
	end if;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `LinkPostImage` (IN `postId` INT, IN `image` VARCHAR(1024))  NO SQL
begin
	update posts set `image` = image where id = postId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `LinkUserImage` (IN `userId` INT, IN `image` VARCHAR(2048))  NO SQL
begin
	update users set photo = image where id = userId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `Login` (IN `login` VARCHAR(256), IN `password` VARCHAR(256))  NO SQL
begin
	select u.id from users as u where u.nickname = login and u.password = password;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `Register` (IN `login` VARCHAR(1024), IN `email` VARCHAR(1024), IN `firstName` VARCHAR(1024), IN `password` VARCHAR(1024))  NO SQL
begin
	select count(u.id) from users as u where u.nickname like login into @count;
	if @count > 0 then
		select 0 as answer;		
	else
		insert into users (nickname, email, firstName, password, dateOfRegistration) values (login, email, firstName, password, now());
		select 1 as answer;
	end if;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `RemoveOffer` (IN `offerId` INT)  NO SQL
begin
	delete from offers where id = offerId;
	delete from offerCharacteristics where offer_id = offerId;
	delete from images where offer_id = offerId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `RemoveOfferImage` (IN `imageId` INT)  NO SQL
begin
	select i.offer_id, i.is_preview into @offerId, @isPreview from images as i where i.id = imageId;
	delete from images where id = imageId;
	select count(i.id) into @i from images as i where i.offer_id = @offerId;
	if @i > 0 and @isPreview = 1 then
		select i.id into @id from images as i where i.offer_id = @offerId limit 1;
		update images set is_preview = 1 where id = @id;
	end if;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `RemovePost` (IN `postId` INT)  NO SQL
begin
	delete from posts where id = postId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `RemovePostImage` (IN `postId` INT)  NO SQL
begin
	update posts set image = "" where id = postId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `RemoveUserImage` (IN `userId` INT)  NO SQL
begin
	update users set photo = "" where id = userId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `SetOfferPreviewImage` (IN `offerId` INT, IN `imageId` INT)  NO SQL
begin
	update images set is_preview = 0 where offer_id = offerId;
	update images set is_preview = 1 where id = imageId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `UpdateOffer` (IN `title` VARCHAR(2048) CHARSET utf8, IN `description` VARCHAR(15360) CHARSET utf8, IN `location` VARCHAR(2048) CHARSET utf8, IN `video` VARCHAR(2048) CHARSET utf8, IN `category_id` INT, IN `characteristics` VARCHAR(4096) CHARSET utf8, IN `offerId` INT)  NO SQL
begin
	update offers set `title` = title, `description` = description, `location` = location, `video` = video, `category_id` = category_id where id = offerId;
	delete from offerCharacteristics where offer_id = offerId;
	if length(characteristics) > 0 then
		set @query = "insert into offerCharacteristics (value, offer_id, characteristic_id) values";
		set @count = length(characteristics) - length(replace(characteristics, "][", " "));
		set @count = @count + 1;
        set @i = 0;
        set @start = 2;
        while @i < @count do
            set @array = substring_index(characteristics, "]", @i + 1);
            set @array = substring(@array, @start, length(@array) - @start);
            set @start = length(@array) + @start + 3;
            set @characteristicId = substring_index(@array, ";", 1);
            set @l1 = length(@characteristicId);
            set @l2 = length(substring_index(@array, ";", 2)) - (@l1 + 1);
            set @value = substring(@array, @l1 + 2, @l2);
            set @i = @i + 1;
			set @query = concat(@query, " ('", @value, "', '", offerId, "', '", @characteristicId, "'),");
        end while;
		set @query = substring(@query, 1, length(@query) - 1);
		prepare query from @query;
		execute query;
		deallocate prepare query;
	end if;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `UpdatePost` (IN `postId` INT, IN `title` VARCHAR(1024) CHARSET utf8, IN `content` VARCHAR(16384) CHARSET utf8)  NO SQL
begin
	update posts set `title` = title, `content` = content where id = postId;
end$$

CREATE DEFINER=`applingi`@`localhost` PROCEDURE `UpdateUser` (IN `userId` INT, IN `nickname` VARCHAR(256) CHARSET utf8, IN `password` VARCHAR(256) CHARSET utf8, IN `firstName` VARCHAR(512) CHARSET utf8, IN `lastName` VARCHAR(512) CHARSET utf8, IN `email` VARCHAR(512) CHARSET utf8, IN `telephone` VARCHAR(64) CHARSET utf8, IN `site` VARCHAR(256) CHARSET utf8, IN `position` VARCHAR(512) CHARSET utf8, IN `experience` VARCHAR(64) CHARSET utf8, IN `country` VARCHAR(512) CHARSET utf8, IN `dateOfBirth` DATETIME, IN `about` VARCHAR(8192) CHARSET utf8)  NO SQL
begin
	update users set `nickname` = nickname, `firstName` = firstName, `lastName` = lastName, `email` = email, `telephone` = telephone, `site` = site, `position` = position, `experience` = experience, `country` = country, `dateOfBirth` = dateOfBirth, `about` = about where id = userId;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `title` varchar(1024) NOT NULL,
  `category_group_id` int(11) NOT NULL,
  `parent_category_id` int(11) NOT NULL,
  `characteristic_group_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `categories`
--

INSERT INTO `categories` (`id`, `title`, `category_group_id`, `parent_category_id`, `characteristic_group_id`) VALUES
(1, 'Продажа', 1, 0, 0),
(2, 'Коммерческая недвижимость', 2, 1, 0),
(3, 'Автосервисы, СТО, шиномонтажи, автомойки', 4, 2, 1),
(4, 'Аптеки, клиники, мед. кабинеты', 4, 2, 1),
(5, 'Бани, сауны', 4, 2, 1),
(6, 'Гаражи', 4, 2, 1),
(7, 'Заправки, нефтебазы', 4, 2, 1),
(8, 'Здания', 4, 2, 1),
(9, 'Магазины', 4, 2, 1),
(10, 'Ночные клубы, бильярдные клубы', 4, 2, 1),
(11, 'Отели, гостиницы, хостелы', 4, 2, 1),
(12, 'Офисы', 4, 2, 1),
(13, 'Парикмахерские, салоны красоты', 4, 2, 1),
(14, 'Парковки, паркинги, стоянки', 4, 2, 1),
(15, 'Помещения свободного назначения', 4, 2, 1),
(16, 'Производство и промышленность', 4, 2, 1),
(17, 'Рестораны, кафе', 4, 2, 1),
(18, 'Санатории, пансионаты, базы отдыха', 4, 2, 1),
(19, 'Склады', 4, 2, 1),
(20, 'Торговые центры, бизнес центры', 4, 2, 1),
(21, 'Фитнес клубы, спортзалы', 4, 2, 1),
(22, 'Жилая недвижимость', 2, 1, 0),
(23, 'Апартаменты', 4, 22, 1),
(24, 'Дачи', 4, 22, 3),
(25, 'Дома', 4, 22, 3),
(26, 'Квартиры (Вторичный рынок)', 4, 22, 1),
(27, 'Квартиры (Новостройка)', 4, 22, 1),
(28, 'Комнаты', 4, 22, 1),
(29, 'Коттеджи', 4, 22, 3),
(30, 'Земля', 2, 1, 0),
(31, 'Для объектов отдыха и здоровья', 4, 30, 2),
(32, 'Для сельского хозяйства', 4, 30, 2),
(33, 'Для строительства жилья', 4, 30, 2),
(34, 'Для строительства коммерческих объектов', 4, 30, 2),
(35, 'Аренда', 1, 0, 0),
(36, 'Долгосрочная аренда', 3, 35, 0),
(37, 'Коммерческая недвижимость', 2, 36, 0),
(38, 'Автосервисы, СТО, шиномонтажи, автомойки', 4, 37, 1),
(39, 'Аптеки, клиники, мед. кабинеты', 4, 37, 1),
(40, 'Бани, сауны', 4, 37, 1),
(41, 'Гаражи', 4, 37, 1),
(42, 'Заправки, нефтебазы', 4, 37, 1),
(43, 'Здания', 4, 37, 1),
(44, 'Магазины', 4, 37, 1),
(45, 'Ночные клубы, бильярдные клубы', 4, 37, 1),
(46, 'Отели, гостиницы, хостелы', 4, 37, 1),
(47, 'Офисы', 4, 37, 1),
(48, 'Парикмахерские, салоны красоты', 4, 37, 1),
(49, 'Парковки, паркинги, стоянки', 4, 37, 1),
(50, 'Помещения свободного назначения', 4, 37, 1),
(51, 'Производство и промышленность', 4, 37, 1),
(52, 'Рестораны, кафе', 4, 37, 1),
(53, 'Санатории, пансионаты, базы отдыха', 4, 37, 1),
(54, 'Склады', 4, 37, 1),
(55, 'Торговые центры, бизнес центры', 4, 37, 1),
(56, 'Фитнес клубы, спортзалы', 4, 37, 1),
(57, 'Жилая недвижимость', 2, 36, 0),
(58, 'Апартаменты', 4, 57, 1),
(59, 'Дачи', 4, 57, 3),
(60, 'Дома', 4, 57, 3),
(61, 'Квартиры', 4, 57, 1),
(62, 'Комнаты', 4, 57, 1),
(63, 'Коттеджи', 4, 57, 3),
(64, 'Посуточная аренда', 3, 35, 0),
(65, 'Коммерческая недвижимость', 2, 64, 0),
(66, 'Бани, сауны', 4, 65, 1),
(67, 'Бизнес центры', 4, 65, 1),
(68, 'Ночные клубы, бильярдные клубы', 4, 65, 1),
(69, 'Отели, гостиницы, хостелы', 4, 65, 1),
(70, 'Офисы', 4, 65, 1),
(71, 'Парковки, паркинги, стоянки', 4, 65, 1),
(72, 'Помещения свободного назначения', 4, 65, 1),
(73, 'Рестораны, кафе', 4, 65, 1),
(74, 'Склады, камеры хранения', 4, 65, 1),
(75, 'Фитнес клубы, спортзалы', 4, 65, 1),
(76, 'Жилая недвижимость', 2, 64, 0),
(77, 'Апартаменты', 4, 76, 1),
(78, 'Дачи', 4, 76, 3),
(79, 'Дома', 4, 76, 3),
(80, 'Квартиры', 4, 76, 1),
(81, 'Комнаты', 4, 76, 1),
(82, 'Коттеджи', 4, 76, 3),
(83, 'Почасовая аренда', 3, 35, 0),
(84, 'Коммерческая недвижимость', 2, 83, 0),
(85, 'Бани, сауны', 4, 84, 1),
(86, 'Бизнес центры', 4, 84, 1),
(87, 'Ночные клубы, бильярдные клубы', 4, 84, 1),
(88, 'Отели, гостиницы, хостелы', 4, 84, 1),
(89, 'Офисы', 4, 84, 1),
(90, 'Парковки, паркинги, стоянки', 4, 84, 1),
(91, 'Паркоместа', 4, 84, 1),
(92, 'Помещения свободного назначения', 4, 84, 1),
(93, 'Рестораны, кафе', 4, 84, 1),
(94, 'Склады, камеры хранения', 4, 84, 1),
(95, 'Фитнес клубы, спортзалы', 4, 84, 1),
(96, 'Жилая недвижимость', 2, 83, 0),
(97, 'Апартаменты', 4, 96, 1),
(98, 'Дачи', 4, 96, 3),
(99, 'Дома', 4, 96, 3),
(100, 'Квартиры', 4, 96, 1),
(101, 'Комнаты', 4, 96, 1),
(102, 'Коттеджи', 4, 96, 3),
(103, 'Покупка', 1, 0, 0),
(104, 'Коммерческая недвижимость', 2, 103, 0),
(105, 'Автосервисы, СТО, шиномонтажи, автомойки', 4, 104, 1),
(106, 'Аптеки, клиники, мед. кабинеты', 4, 104, 1),
(107, 'Бани, сауны', 4, 104, 1),
(108, 'Гаражи', 4, 104, 1),
(109, 'Заправки, нефтебазы', 4, 104, 1),
(110, 'Здания', 4, 104, 1),
(111, 'Магазины', 4, 104, 1),
(112, 'Ночные клубы, бильярдные клубы', 4, 104, 1),
(113, 'Отели, гостиницы, хостелы', 4, 104, 1),
(114, 'Офисы', 4, 104, 1),
(115, 'Парикмахерские, салоны красоты', 4, 104, 1),
(116, 'Парковки, паркинги, стоянки', 4, 104, 1),
(117, 'Помещения свободного назначения', 4, 104, 1),
(118, 'Производство и промышленность', 4, 104, 1),
(119, 'Рестораны, кафе', 4, 104, 1),
(120, 'Санатории, пансионаты, базы отдыха', 4, 104, 1),
(121, 'Склады', 4, 104, 1),
(122, 'Торговые центры, бизнес центры', 4, 104, 1),
(123, 'Фитнес клубы, спортзалы', 4, 104, 1),
(124, 'Жилая недвижимость', 2, 103, 0),
(125, 'Апартаменты', 4, 124, 1),
(126, 'Дачи', 4, 124, 3),
(127, 'Дома', 4, 124, 3),
(128, 'Квартиры (Вторичный рынок)', 4, 124, 1),
(129, 'Квартиры (Новостройка)', 4, 124, 1),
(130, 'Комнаты', 4, 124, 1),
(131, 'Коттеджи', 4, 124, 3),
(132, 'Земля', 2, 103, 0),
(133, 'Для объектов отдыха и здоровья', 4, 132, 1),
(134, 'Для сельского хозяйства', 4, 132, 1),
(135, 'Для строительства жилья', 4, 132, 1),
(136, 'Для строительства коммерческих объектов', 4, 132, 1),
(137, 'Сдача в аренду', 1, 0, 0),
(138, 'Долгосрочная аренда', 3, 137, 0),
(139, 'Коммерческая недвижимость', 2, 138, 0),
(140, 'Автосервисы, СТО, шиномонтажи, автомойки', 4, 139, 1),
(141, 'Аптеки, клиники, мед. кабинеты', 4, 139, 1),
(142, 'Бани, сауны', 4, 139, 1),
(143, 'Гаражи', 4, 139, 1),
(144, 'Заправки, нефтебазы', 4, 139, 1),
(145, 'Здания', 4, 139, 1),
(146, 'Магазины', 4, 139, 1),
(147, 'Ночные клубы, бильярдные клубы', 4, 139, 1),
(148, 'Отели, гостиницы, хостелы', 4, 139, 1),
(149, 'Офисы', 4, 139, 1),
(150, 'Парикмахерские, салоны красоты', 4, 139, 1),
(151, 'Парковки, паркинги, стоянки', 4, 139, 1),
(152, 'Помещения свободного назначения', 4, 139, 1),
(153, 'Производство и промышленность', 4, 139, 1),
(154, 'Рестораны, кафе', 4, 139, 1),
(155, 'Санатории, пансионаты, базы отдыха', 4, 139, 1),
(156, 'Склады', 4, 139, 1),
(157, 'Торговые центры, бизнес центры', 4, 139, 1),
(158, 'Фитнес клубы, спортзалы', 4, 139, 1),
(159, 'Жилая недвижимость', 2, 138, 0),
(160, 'Апартаменты', 4, 159, 1),
(161, 'Дачи', 4, 159, 3),
(162, 'Дома', 4, 159, 3),
(163, 'Квартиры', 4, 159, 1),
(164, 'Комнаты', 4, 159, 1),
(165, 'Коттеджи', 4, 159, 3),
(166, 'Посуточная аренда', 3, 137, 0),
(167, 'Коммерческая недвижимость', 2, 166, 0),
(168, 'Бани, сауны', 4, 167, 1),
(169, 'Бизнес центры', 4, 167, 1),
(170, 'Ночные клубы, бильярдные клубы', 4, 167, 1),
(171, 'Отели, гостиницы, хостелы', 4, 167, 1),
(172, 'Офисы', 4, 167, 1),
(173, 'Парковки, паркинги, стоянки', 4, 167, 1),
(174, 'Помещения свободного назначения', 4, 167, 1),
(175, 'Рестораны, кафе', 4, 167, 1),
(176, 'Склады, камеры хранения', 4, 167, 1),
(177, 'Фитнес клубы, спортзалы', 4, 167, 1),
(178, 'Жилая недвижимость', 2, 166, 0),
(179, 'Апартаменты', 4, 178, 1),
(180, 'Дачи', 4, 178, 3),
(181, 'Дома', 4, 178, 3),
(182, 'Квартиры', 4, 178, 1),
(183, 'Комнаты', 4, 178, 1),
(184, 'Коттеджи', 4, 178, 3),
(185, 'Почасовая аренда', 3, 137, 0),
(186, 'Коммерческая недвижимость', 2, 185, 0),
(187, 'Бани, сауны', 4, 186, 1),
(188, 'Бизнес центры', 4, 186, 1),
(189, 'Ночные клубы, бильярдные клубы', 4, 186, 1),
(190, 'Отели, гостиницы, хостелы', 4, 186, 1),
(191, 'Офисы', 4, 186, 1),
(192, 'Парковки, паркинги, стоянки', 4, 186, 1),
(193, 'Паркоместа', 4, 186, 1),
(194, 'Помещения свободного назначения', 4, 186, 1),
(195, 'Рестораны, кафе', 4, 186, 1),
(196, 'Склады, камеры хранения', 4, 186, 1),
(197, 'Фитнес клубы, спортзалы', 4, 186, 1),
(198, 'Жилая недвижимость', 2, 185, 0),
(199, 'Апартаменты', 4, 198, 1),
(200, 'Дачи', 4, 198, 3),
(201, 'Дома', 4, 198, 3),
(202, 'Квартиры', 4, 198, 1),
(203, 'Комнаты', 4, 198, 1),
(204, 'Коттеджи', 4, 198, 3);

-- --------------------------------------------------------

--
-- Структура таблицы `categoryGroups`
--

CREATE TABLE `categoryGroups` (
  `id` int(11) NOT NULL,
  `title` varchar(1024) NOT NULL,
  `precision` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `categoryGroups`
--

INSERT INTO `categoryGroups` (`id`, `title`, `precision`) VALUES
(1, 'Действие', 1),
(2, 'Тип', 1),
(3, 'Тип аренды', 1),
(4, 'Объект', 2);

-- --------------------------------------------------------

--
-- Структура таблицы `characteristics`
--

CREATE TABLE `characteristics` (
  `id` int(11) NOT NULL,
  `title` varchar(1024) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `characteristic_type_id` int(11) NOT NULL,
  `characteristic_group_id` int(11) NOT NULL,
  `parent_characteristic_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `characteristics`
--

INSERT INTO `characteristics` (`id`, `title`, `unit_id`, `characteristic_type_id`, `characteristic_group_id`, `parent_characteristic_id`) VALUES
(1, 'Цена', 0, 0, 1, 0),
(2, 'Полная цена', 4, 1, 1, 1),
(3, 'Цена за м2', 4, 1, 1, 1),
(4, 'Этажность', 0, 0, 1, 0),
(5, 'Этаж', 0, 1, 1, 4),
(6, 'Количество этажей', 0, 1, 1, 4),
(7, 'Площадь', 0, 0, 1, 0),
(8, 'Полная площадь', 1, 1, 1, 7),
(9, 'Жилая площадь', 1, 1, 1, 7),
(10, 'Общие', 0, 0, 1, 0),
(11, 'Количество комнат', 0, 1, 1, 10),
(12, 'Год постройки', 0, 1, 1, 10),
(13, 'Наличие лифта', 0, 3, 1, 10),
(14, 'С лифтом', 0, 2, 1, 13),
(15, 'Без лифта', 0, 2, 1, 13),
(16, 'Состояние', 0, 3, 1, 0),
(17, 'Дизайнерский ремонт', 0, 2, 1, 16),
(18, 'Евроремонт', 0, 2, 1, 16),
(19, 'Косметический ремонт', 0, 2, 1, 16),
(20, 'После реконструкции', 0, 2, 1, 16),
(21, 'Жилое состояние', 0, 2, 1, 16),
(22, 'Требуется косметический ремонт', 0, 2, 1, 16),
(23, 'Неоконченный ремонт', 0, 2, 1, 16),
(24, 'Под чистовую отделку', 0, 2, 1, 16),
(25, 'Требуется капитальный ремонт', 0, 2, 1, 16),
(26, 'Незавершённое строительство', 0, 2, 1, 16),
(27, 'Без ремонта', 0, 2, 1, 16),
(28, 'Цена', 0, 0, 2, 0),
(29, 'Полная цена', 4, 1, 2, 28),
(30, 'Цена за сотку', 4, 1, 2, 28),
(31, 'Площадь', 0, 0, 2, 0),
(32, 'Полная площадь', 6, 1, 2, 31),
(33, 'Цена', 0, 0, 3, 0),
(34, 'Полная цена', 4, 1, 3, 33),
(35, 'Цена за м2', 4, 1, 3, 33),
(36, 'Этажность', 0, 0, 3, 0),
(37, 'Этаж', 0, 1, 3, 36),
(38, 'Количество этажей', 0, 1, 3, 36),
(39, 'Площадь', 0, 0, 3, 0),
(40, 'Полная площадь', 1, 1, 3, 39),
(41, 'Жилая площадь', 1, 1, 3, 39),
(42, 'Площадь участка', 6, 1, 3, 39),
(43, 'Общие', 0, 0, 3, 0),
(44, 'Количество комнат', 0, 1, 3, 43),
(45, 'Год постройки', 0, 1, 3, 43),
(46, 'Наличие лифта', 0, 3, 3, 43),
(47, 'С лифтом', 0, 2, 3, 46),
(48, 'Без лифта', 0, 2, 3, 46),
(49, 'Состояние', 0, 3, 3, 0),
(50, 'Дизайнерский ремонт', 0, 2, 3, 49),
(51, 'Евроремонт', 0, 2, 3, 49),
(52, 'Косметический ремонт', 0, 2, 3, 49),
(53, 'После реконструкции', 0, 2, 3, 49),
(54, 'Жилое состояние', 0, 2, 3, 49),
(55, 'Требуется косметический ремонт', 0, 2, 3, 49),
(56, 'Неоконченный ремонт', 0, 2, 3, 49),
(57, 'Под чистовую отделку', 0, 2, 3, 49),
(58, 'Требуется капитальный ремонт', 0, 2, 3, 49),
(59, 'Незавершённое строительство', 0, 2, 3, 49),
(60, 'Без ремонта', 0, 2, 3, 49);

-- --------------------------------------------------------

--
-- Структура таблицы `images`
--

CREATE TABLE `images` (
  `id` int(11) NOT NULL,
  `path` varchar(2048) NOT NULL,
  `offer_id` int(11) NOT NULL,
  `is_preview` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `images`
--

INSERT INTO `images` (`id`, `path`, `offer_id`, `is_preview`) VALUES
(88, 'offer_image-0.png', 9, 0),
(1000, 'offer_image-789.jpeg', 13, 1),
(673, 'offer_image-481.jpeg', 11, 0),
(130, 'offer_image-23.jpeg', 13, 0),
(131, 'offer_image-24.jpeg', 13, 0),
(137, 'offer_image-27.jpeg', 17, 1),
(138, 'offer_image-30.jpeg', 17, 0),
(139, 'offer_image-31.jpeg', 17, 0),
(140, 'offer_image-32.jpeg', 17, 0),
(141, 'offer_image-33.jpeg', 17, 0),
(142, 'offer_image-34.jpeg', 17, 0),
(143, 'offer_image-35.jpeg', 17, 0),
(144, 'offer_image-36.jpeg', 17, 0),
(155, 'offer_image-39.jpeg', 18, 0),
(156, 'offer_image-40.jpeg', 18, 0),
(157, 'offer_image-41.jpeg', 18, 0),
(158, 'offer_image-42.jpeg', 18, 0),
(154, 'offer_image-38.jpeg', 18, 0),
(153, 'offer_image-37.jpeg', 18, 1),
(159, 'offer_image-43.jpeg', 18, 0),
(160, 'offer_image-44.jpeg', 18, 0),
(161, 'offer_image-45.jpeg', 19, 1),
(162, 'offer_image-46.jpeg', 19, 0),
(163, 'offer_image-47.jpeg', 19, 0),
(164, 'offer_image-48.jpeg', 19, 0),
(165, 'offer_image-49.jpeg', 19, 0),
(166, 'offer_image-50.jpeg', 19, 0),
(167, 'offer_image-51.jpeg', 19, 0),
(168, 'offer_image-52.jpeg', 20, 0),
(169, 'offer_image-53.jpeg', 20, 0),
(170, 'offer_image-54.jpeg', 20, 1),
(171, 'offer_image-55.jpeg', 20, 0),
(172, 'offer_image-56.jpeg', 20, 0),
(182, 'offer_image-61.jpeg', 21, 0),
(183, 'offer_image-62.jpeg', 21, 0),
(184, 'offer_image-63.jpeg', 22, 1),
(178, 'offer_image-57.jpeg', 21, 0),
(179, 'offer_image-58.jpeg', 21, 1),
(180, 'offer_image-59.jpeg', 21, 0),
(181, 'offer_image-60.jpeg', 21, 0),
(185, 'offer_image-64.jpeg', 22, 0),
(186, 'offer_image-65.jpeg', 22, 0),
(187, 'offer_image-66.jpeg', 22, 0),
(188, 'offer_image-67.jpeg', 22, 0),
(189, 'offer_image-68.jpeg', 22, 0),
(190, 'offer_image-69.jpeg', 22, 0),
(191, 'offer_image-70.jpeg', 22, 0),
(192, 'offer_image-71.jpeg', 23, 0),
(194, 'offer_image-73.jpeg', 23, 0),
(195, 'offer_image-74.jpeg', 23, 0),
(196, 'offer_image-75.jpeg', 23, 0),
(197, 'offer_image-76.jpeg', 23, 0),
(198, 'offer_image-77.jpeg', 23, 1),
(1144, 'offer_image-930.jpeg', 128, 0),
(289, 'offer_image-98.jpeg', 34, 1),
(288, 'offer_image-97.jpeg', 33, 0),
(287, 'offer_image-96.jpeg', 33, 0),
(206, 'offer_image-78.jpeg', 24, 0),
(286, 'offer_image-95.jpeg', 33, 0),
(285, 'offer_image-94.jpeg', 33, 0),
(284, 'offer_image-93.jpeg', 33, 0),
(283, 'offer_image-92.jpeg', 33, 0),
(282, 'offer_image-91.jpeg', 33, 1),
(281, 'offer_image-90.jpeg', 33, 0),
(294, 'offer_image-103.jpeg', 34, 0),
(293, 'offer_image-102.jpeg', 34, 0),
(292, 'offer_image-101.jpeg', 34, 0),
(291, 'offer_image-100.jpeg', 34, 0),
(290, 'offer_image-99.jpeg', 34, 0),
(321, 'offer_image-135.jpeg', 39, 1),
(320, 'offer_image-129.jpeg', 38, 0),
(318, 'offer_image-127.jpeg', 38, 0),
(317, 'offer_image-126.jpeg', 38, 0),
(299, 'offer_image-108.jpeg', 35, 0),
(298, 'offer_image-107.jpeg', 35, 0),
(297, 'offer_image-106.jpeg', 35, 1),
(296, 'offer_image-105.jpeg', 34, 0),
(295, 'offer_image-104.jpeg', 34, 0),
(764, 'offer_image-557.jpeg', 36, 0),
(763, 'offer_image-556.jpeg', 36, 0),
(762, 'offer_image-555.jpeg', 36, 0),
(300, 'offer_image-109.jpeg', 35, 0),
(308, 'offer_image-117.jpeg', 37, 0),
(307, 'offer_image-116.jpeg', 37, 1),
(761, 'offer_image-554.jpeg', 36, 0),
(760, 'offer_image-553.jpeg', 36, 1),
(759, 'offer_image-552.jpeg', 36, 0),
(313, 'offer_image-122.jpeg', 37, 0),
(312, 'offer_image-121.jpeg', 37, 0),
(311, 'offer_image-120.jpeg', 37, 0),
(310, 'offer_image-119.jpeg', 37, 0),
(309, 'offer_image-118.jpeg', 37, 0),
(316, 'offer_image-125.jpeg', 38, 0),
(315, 'offer_image-124.jpeg', 38, 0),
(314, 'offer_image-123.jpeg', 38, 1),
(322, 'offer_image-136.jpeg', 39, 0),
(323, 'offer_image-137.jpeg', 39, 0),
(324, 'offer_image-138.jpeg', 39, 0),
(325, 'offer_image-139.jpeg', 39, 0),
(326, 'offer_image-140.jpeg', 39, 0),
(327, 'offer_image-141.jpeg', 39, 0),
(766, 'offer_image-559.jpeg', 40, 1),
(767, 'offer_image-560.jpeg', 40, 0),
(768, 'offer_image-561.jpeg', 40, 0),
(769, 'offer_image-562.jpeg', 40, 0),
(770, 'offer_image-563.jpeg', 40, 0),
(771, 'offer_image-564.jpeg', 40, 0),
(336, 'offer_image-150.jpeg', 41, 1),
(337, 'offer_image-151.jpeg', 41, 0),
(338, 'offer_image-152.jpeg', 41, 0),
(339, 'offer_image-153.jpeg', 41, 0),
(340, 'offer_image-154.jpeg', 41, 0),
(341, 'offer_image-155.jpeg', 41, 0),
(342, 'offer_image-156.jpeg', 42, 1),
(343, 'offer_image-157.jpeg', 42, 0),
(344, 'offer_image-158.jpeg', 42, 0),
(345, 'offer_image-159.jpeg', 42, 0),
(346, 'offer_image-160.jpeg', 42, 0),
(347, 'offer_image-161.jpeg', 42, 0),
(348, 'offer_image-162.jpeg', 42, 0),
(349, 'offer_image-163.jpeg', 42, 0),
(350, 'offer_image-164.jpeg', 43, 1),
(351, 'offer_image-165.jpeg', 43, 0),
(352, 'offer_image-166.jpeg', 43, 0),
(353, 'offer_image-167.jpeg', 43, 0),
(354, 'offer_image-168.jpeg', 44, 1),
(355, 'offer_image-169.jpeg', 44, 0),
(356, 'offer_image-170.jpeg', 44, 0),
(357, 'offer_image-171.jpeg', 44, 0),
(358, 'offer_image-172.jpeg', 44, 0),
(359, 'offer_image-173.jpeg', 44, 0),
(360, 'offer_image-174.jpeg', 44, 0),
(361, 'offer_image-175.jpeg', 45, 1),
(362, 'offer_image-176.jpeg', 45, 0),
(363, 'offer_image-177.jpeg', 45, 0),
(364, 'offer_image-178.jpeg', 45, 0),
(365, 'offer_image-179.jpeg', 45, 0),
(366, 'offer_image-180.jpeg', 45, 0),
(367, 'offer_image-181.jpeg', 45, 0),
(368, 'offer_image-182.jpeg', 45, 0),
(369, 'offer_image-183.jpeg', 46, 1),
(370, 'offer_image-184.jpeg', 46, 0),
(371, 'offer_image-185.jpeg', 46, 0),
(372, 'offer_image-186.jpeg', 46, 0),
(373, 'offer_image-187.jpeg', 46, 0),
(374, 'offer_image-188.jpeg', 47, 1),
(375, 'offer_image-189.jpeg', 47, 0),
(376, 'offer_image-190.jpeg', 47, 0),
(377, 'offer_image-191.jpeg', 47, 0),
(378, 'offer_image-192.jpeg', 47, 0),
(683, 'offer_image-490.jpeg', 91, 1),
(684, 'offer_image-491.jpeg', 91, 0),
(383, 'offer_image-197.jpeg', 48, 0),
(685, 'offer_image-492.jpeg', 91, 0),
(385, 'offer_image-199.jpeg', 48, 1),
(386, 'offer_image-200.jpeg', 48, 0),
(387, 'offer_image-201.jpeg', 49, 1),
(715, 'offer_image-522.jpeg', 96, 0),
(389, 'offer_image-203.jpeg', 49, 0),
(390, 'offer_image-204.jpeg', 49, 0),
(391, 'offer_image-205.jpeg', 49, 0),
(392, 'offer_image-206.jpeg', 49, 0),
(393, 'offer_image-207.jpeg', 49, 0),
(394, 'offer_image-208.jpeg', 50, 0),
(714, 'offer_image-521.jpeg', 96, 0),
(397, 'offer_image-211.jpeg', 50, 0),
(398, 'offer_image-212.jpeg', 50, 0),
(399, 'offer_image-213.jpeg', 50, 0),
(400, 'offer_image-214.jpeg', 50, 0),
(401, 'offer_image-215.jpeg', 50, 0),
(402, 'offer_image-216.jpeg', 51, 1),
(403, 'offer_image-217.jpeg', 51, 0),
(404, 'offer_image-218.jpeg', 51, 0),
(405, 'offer_image-219.jpeg', 51, 0),
(406, 'offer_image-220.jpeg', 51, 0),
(407, 'offer_image-221.jpeg', 51, 0),
(408, 'offer_image-222.jpeg', 51, 0),
(409, 'offer_image-223.jpeg', 51, 0),
(410, 'offer_image-224.jpeg', 52, 1),
(412, 'offer_image-226.jpeg', 52, 0),
(413, 'offer_image-227.jpeg', 52, 0),
(414, 'offer_image-228.jpeg', 52, 0),
(415, 'offer_image-229.jpeg', 52, 0),
(416, 'offer_image-230.jpeg', 52, 0),
(417, 'offer_image-231.jpeg', 52, 0),
(420, 'offer_image-234.jpeg', 53, 0),
(421, 'offer_image-235.jpeg', 53, 0),
(774, 'offer_image-566.jpeg', 53, 1),
(423, 'offer_image-237.jpeg', 53, 0),
(424, 'offer_image-238.jpeg', 54, 1),
(425, 'offer_image-239.jpeg', 54, 0),
(426, 'offer_image-240.jpeg', 54, 0),
(427, 'offer_image-241.jpeg', 54, 0),
(428, 'offer_image-242.jpeg', 54, 0),
(429, 'offer_image-243.jpeg', 54, 0),
(430, 'offer_image-244.jpeg', 54, 0),
(431, 'offer_image-245.jpeg', 54, 0),
(432, 'offer_image-246.jpeg', 55, 1),
(433, 'offer_image-247.jpeg', 55, 0),
(434, 'offer_image-248.jpeg', 55, 0),
(435, 'offer_image-249.jpeg', 55, 0),
(436, 'offer_image-250.jpeg', 55, 0),
(437, 'offer_image-251.jpeg', 55, 0),
(438, 'offer_image-252.jpeg', 55, 0),
(439, 'offer_image-253.jpeg', 56, 1),
(440, 'offer_image-254.jpeg', 56, 0),
(441, 'offer_image-255.jpeg', 56, 0),
(442, 'offer_image-256.jpeg', 56, 0),
(443, 'offer_image-257.jpeg', 56, 0),
(444, 'offer_image-258.jpeg', 56, 0),
(445, 'offer_image-259.jpeg', 56, 0),
(446, 'offer_image-260.jpeg', 56, 0),
(447, 'offer_image-261.jpeg', 57, 1),
(448, 'offer_image-262.jpeg', 57, 0),
(449, 'offer_image-263.jpeg', 57, 0),
(450, 'offer_image-264.jpeg', 57, 0),
(451, 'offer_image-265.jpeg', 57, 0),
(452, 'offer_image-266.jpeg', 57, 0),
(453, 'offer_image-267.jpeg', 57, 0),
(454, 'offer_image-268.jpeg', 57, 0),
(455, 'offer_image-269.jpeg', 58, 1),
(456, 'offer_image-270.jpeg', 58, 0),
(457, 'offer_image-271.jpeg', 58, 0),
(458, 'offer_image-272.jpeg', 58, 0),
(459, 'offer_image-273.jpeg', 58, 0),
(460, 'offer_image-274.jpeg', 58, 0),
(461, 'offer_image-275.jpeg', 58, 0),
(462, 'offer_image-276.jpeg', 58, 0),
(463, 'offer_image-277.jpeg', 59, 1),
(464, 'offer_image-278.jpeg', 59, 0),
(465, 'offer_image-279.jpeg', 59, 0),
(466, 'offer_image-280.jpeg', 59, 0),
(467, 'offer_image-281.jpeg', 59, 0),
(468, 'offer_image-282.jpeg', 59, 0),
(469, 'offer_image-283.jpeg', 59, 0),
(470, 'offer_image-284.jpeg', 59, 0),
(471, 'offer_image-285.jpeg', 60, 1),
(472, 'offer_image-286.jpeg', 60, 0),
(473, 'offer_image-287.jpeg', 60, 0),
(474, 'offer_image-288.jpeg', 60, 0),
(475, 'offer_image-289.jpeg', 60, 0),
(476, 'offer_image-290.jpeg', 60, 0),
(502, 'offer_image-310.jpeg', 66, 1),
(501, 'offer_image-309.jpeg', 65, 0),
(500, 'offer_image-308.jpeg', 65, 0),
(499, 'offer_image-307.jpeg', 65, 0),
(498, 'offer_image-306.jpeg', 65, 0),
(497, 'offer_image-305.jpeg', 65, 0),
(496, 'offer_image-304.jpeg', 65, 1),
(489, 'offer_image-297.jpeg', 64, 1),
(490, 'offer_image-298.jpeg', 64, 0),
(491, 'offer_image-299.jpeg', 64, 0),
(492, 'offer_image-300.jpeg', 64, 0),
(493, 'offer_image-301.jpeg', 64, 0),
(494, 'offer_image-302.jpeg', 64, 0),
(495, 'offer_image-303.jpeg', 64, 0),
(503, 'offer_image-311.jpeg', 66, 0),
(504, 'offer_image-312.jpeg', 66, 0),
(505, 'offer_image-313.jpeg', 66, 0),
(506, 'offer_image-314.jpeg', 66, 0),
(507, 'offer_image-315.jpeg', 66, 0),
(508, 'offer_image-316.jpeg', 66, 0),
(509, 'offer_image-317.jpeg', 66, 0),
(510, 'offer_image-318.jpeg', 67, 1),
(511, 'offer_image-319.jpeg', 67, 0),
(512, 'offer_image-320.jpeg', 67, 0),
(513, 'offer_image-321.jpeg', 67, 0),
(514, 'offer_image-322.jpeg', 67, 0),
(515, 'offer_image-323.jpeg', 67, 0),
(516, 'offer_image-324.jpeg', 67, 0),
(517, 'offer_image-325.jpeg', 68, 1),
(518, 'offer_image-326.jpeg', 68, 0),
(519, 'offer_image-327.jpeg', 68, 0),
(520, 'offer_image-328.jpeg', 68, 0),
(521, 'offer_image-329.jpeg', 68, 0),
(522, 'offer_image-330.jpeg', 68, 0),
(523, 'offer_image-331.jpeg', 68, 0),
(524, 'offer_image-332.jpeg', 69, 1),
(525, 'offer_image-333.jpeg', 69, 0),
(526, 'offer_image-334.jpeg', 69, 0),
(527, 'offer_image-335.jpeg', 69, 0),
(528, 'offer_image-336.jpeg', 69, 0),
(529, 'offer_image-337.jpeg', 69, 0),
(530, 'offer_image-338.jpeg', 69, 0),
(531, 'offer_image-339.jpeg', 69, 0),
(532, 'offer_image-340.jpeg', 70, 1),
(533, 'offer_image-341.jpeg', 70, 0),
(534, 'offer_image-342.jpeg', 70, 0),
(535, 'offer_image-343.jpeg', 70, 0),
(536, 'offer_image-344.jpeg', 70, 0),
(537, 'offer_image-345.jpeg', 70, 0),
(538, 'offer_image-346.jpeg', 71, 1),
(539, 'offer_image-347.jpeg', 71, 0),
(540, 'offer_image-348.jpeg', 71, 0),
(541, 'offer_image-349.jpeg', 72, 1),
(542, 'offer_image-350.jpeg', 72, 0),
(543, 'offer_image-351.jpeg', 72, 0),
(544, 'offer_image-352.jpeg', 72, 0),
(545, 'offer_image-353.jpeg', 72, 0),
(546, 'offer_image-354.jpeg', 72, 0),
(547, 'offer_image-355.jpeg', 73, 1),
(548, 'offer_image-356.jpeg', 73, 0),
(550, 'offer_image-358.jpeg', 73, 0),
(551, 'offer_image-359.jpeg', 73, 0),
(552, 'offer_image-360.jpeg', 73, 0),
(553, 'offer_image-361.jpeg', 73, 0),
(554, 'offer_image-362.jpeg', 74, 1),
(555, 'offer_image-363.jpeg', 74, 0),
(556, 'offer_image-364.jpeg', 74, 0),
(557, 'offer_image-365.jpeg', 74, 0),
(558, 'offer_image-366.jpeg', 74, 0),
(559, 'offer_image-367.jpeg', 74, 0),
(560, 'offer_image-368.jpeg', 74, 0),
(561, 'offer_image-369.jpeg', 74, 0),
(562, 'offer_image-370.jpeg', 75, 0),
(563, 'offer_image-371.jpeg', 75, 0),
(564, 'offer_image-372.jpeg', 75, 0),
(565, 'offer_image-373.jpeg', 75, 0),
(566, 'offer_image-374.jpeg', 75, 0),
(567, 'offer_image-375.jpeg', 75, 0),
(568, 'offer_image-376.jpeg', 75, 0),
(569, 'offer_image-377.jpeg', 76, 1),
(570, 'offer_image-378.jpeg', 76, 0),
(571, 'offer_image-379.jpeg', 76, 0),
(572, 'offer_image-380.jpeg', 76, 0),
(573, 'offer_image-381.jpeg', 76, 0),
(574, 'offer_image-382.jpeg', 76, 0),
(575, 'offer_image-383.jpeg', 76, 0),
(576, 'offer_image-384.jpeg', 76, 0),
(577, 'offer_image-385.jpeg', 77, 1),
(578, 'offer_image-386.jpeg', 77, 0),
(579, 'offer_image-387.jpeg', 77, 0),
(580, 'offer_image-388.jpeg', 77, 0),
(581, 'offer_image-389.jpeg', 77, 0),
(582, 'offer_image-390.jpeg', 77, 0),
(583, 'offer_image-391.jpeg', 77, 0),
(584, 'offer_image-392.jpeg', 78, 1),
(585, 'offer_image-393.jpeg', 78, 0),
(586, 'offer_image-394.jpeg', 78, 0),
(587, 'offer_image-395.jpeg', 78, 0),
(588, 'offer_image-396.jpeg', 78, 0),
(589, 'offer_image-397.jpeg', 78, 0),
(590, 'offer_image-398.jpeg', 78, 0),
(591, 'offer_image-399.jpeg', 78, 0),
(592, 'offer_image-400.jpeg', 79, 1),
(593, 'offer_image-401.jpeg', 79, 0),
(594, 'offer_image-402.jpeg', 79, 0),
(595, 'offer_image-403.jpeg', 79, 0),
(596, 'offer_image-404.jpeg', 79, 0),
(597, 'offer_image-405.jpeg', 79, 0),
(598, 'offer_image-406.jpeg', 79, 0),
(599, 'offer_image-407.jpeg', 80, 1),
(600, 'offer_image-408.jpeg', 80, 0),
(601, 'offer_image-409.jpeg', 80, 0),
(602, 'offer_image-410.jpeg', 80, 0),
(603, 'offer_image-411.jpeg', 80, 0),
(604, 'offer_image-412.jpeg', 80, 0),
(605, 'offer_image-413.jpeg', 81, 1),
(606, 'offer_image-414.jpeg', 81, 0),
(607, 'offer_image-415.jpeg', 81, 0),
(608, 'offer_image-416.jpeg', 81, 0),
(609, 'offer_image-417.jpeg', 81, 0),
(610, 'offer_image-418.jpeg', 82, 1),
(611, 'offer_image-419.jpeg', 82, 0),
(612, 'offer_image-420.jpeg', 82, 0),
(613, 'offer_image-421.jpeg', 82, 0),
(614, 'offer_image-422.jpeg', 82, 0),
(615, 'offer_image-423.jpeg', 82, 0),
(616, 'offer_image-424.jpeg', 82, 0),
(617, 'offer_image-425.jpeg', 82, 0),
(618, 'offer_image-426.jpeg', 83, 1),
(619, 'offer_image-427.jpeg', 83, 0),
(620, 'offer_image-428.jpeg', 83, 0),
(621, 'offer_image-429.jpeg', 83, 0),
(622, 'offer_image-430.jpeg', 83, 0),
(623, 'offer_image-431.jpeg', 83, 0),
(624, 'offer_image-432.jpeg', 83, 0),
(625, 'offer_image-433.jpeg', 83, 0),
(626, 'offer_image-434.jpeg', 83, 0),
(627, 'offer_image-435.jpeg', 84, 0),
(1012, 'offer_image-801.jpeg', 84, 0),
(1149, 'offer_image-935.jpeg', 84, 1),
(630, 'offer_image-438.jpeg', 84, 0),
(631, 'offer_image-439.jpeg', 84, 0),
(1148, 'offer_image-934.jpeg', 84, 0),
(1147, 'offer_image-933.jpeg', 84, 0),
(634, 'offer_image-442.jpeg', 85, 0),
(635, 'offer_image-443.jpeg', 85, 0),
(637, 'offer_image-445.jpeg', 85, 0),
(638, 'offer_image-446.jpeg', 85, 0),
(640, 'offer_image-448.jpeg', 85, 0),
(641, 'offer_image-449.jpeg', 85, 0),
(642, 'offer_image-450.jpeg', 86, 1),
(643, 'offer_image-451.jpeg', 86, 0),
(644, 'offer_image-452.jpeg', 86, 0),
(645, 'offer_image-453.jpeg', 86, 0),
(646, 'offer_image-454.jpeg', 86, 0),
(647, 'offer_image-455.jpeg', 87, 1),
(648, 'offer_image-456.jpeg', 87, 0),
(649, 'offer_image-457.jpeg', 87, 0),
(650, 'offer_image-458.jpeg', 87, 0),
(651, 'offer_image-459.jpeg', 87, 0),
(652, 'offer_image-460.jpeg', 88, 0),
(653, 'offer_image-461.jpeg', 88, 1),
(654, 'offer_image-462.jpeg', 88, 0),
(655, 'offer_image-463.jpeg', 88, 0),
(662, 'offer_image-470.jpeg', 90, 1),
(663, 'offer_image-471.jpeg', 90, 0),
(664, 'offer_image-472.jpeg', 90, 0),
(665, 'offer_image-473.jpeg', 9, 0),
(988, 'offer_image-778.jpeg', 9, 1),
(667, 'offer_image-475.jpeg', 9, 0),
(668, 'offer_image-476.jpeg', 9, 0),
(669, 'offer_image-477.jpeg', 11, 0),
(670, 'offer_image-478.jpeg', 11, 1),
(671, 'offer_image-479.jpeg', 11, 0),
(672, 'offer_image-480.jpeg', 11, 0),
(686, 'offer_image-493.jpeg', 91, 0),
(687, 'offer_image-494.jpeg', 92, 1),
(688, 'offer_image-495.jpeg', 92, 0),
(689, 'offer_image-496.jpeg', 92, 0),
(690, 'offer_image-497.jpeg', 92, 0),
(691, 'offer_image-498.jpeg', 92, 0),
(692, 'offer_image-499.jpeg', 92, 0),
(693, 'offer_image-500.jpeg', 93, 1),
(694, 'offer_image-501.jpeg', 93, 0),
(695, 'offer_image-502.jpeg', 93, 0),
(696, 'offer_image-503.jpeg', 93, 0),
(697, 'offer_image-504.jpeg', 93, 0),
(698, 'offer_image-505.jpeg', 93, 0),
(699, 'offer_image-506.jpeg', 93, 0),
(700, 'offer_image-507.jpeg', 93, 0),
(707, 'offer_image-514.jpeg', 95, 1),
(708, 'offer_image-515.jpeg', 95, 0),
(709, 'offer_image-516.jpeg', 95, 0),
(1078, 'offer_image-865.jpeg', 97, 1),
(711, 'offer_image-518.jpeg', 95, 0),
(712, 'offer_image-519.jpeg', 95, 0),
(713, 'offer_image-520.jpeg', 95, 0),
(716, 'offer_image-523.jpeg', 96, 0),
(717, 'offer_image-524.jpeg', 96, 0),
(718, 'offer_image-525.jpeg', 96, 0),
(719, 'offer_image-526.jpeg', 97, 0),
(875, 'offer_image-667.jpeg', 116, 0),
(874, 'offer_image-666.jpeg', 116, 0),
(873, 'offer_image-665.jpeg', 116, 0),
(872, 'offer_image-664.jpeg', 116, 0),
(871, 'offer_image-663.jpeg', 116, 0),
(870, 'offer_image-662.jpeg', 116, 0),
(869, 'offer_image-661.jpeg', 116, 0),
(868, 'offer_image-660.jpeg', 116, 0),
(867, 'offer_image-659.jpeg', 116, 1),
(880, 'offer_image-672.jpeg', 118, 1),
(879, 'offer_image-671.jpeg', 117, 0),
(878, 'offer_image-670.jpeg', 117, 0),
(877, 'offer_image-669.jpeg', 117, 0),
(876, 'offer_image-668.jpeg', 117, 1),
(758, 'offer_image-551.jpeg', 100, 0),
(757, 'offer_image-550.jpeg', 100, 0),
(756, 'offer_image-549.jpeg', 100, 0),
(755, 'offer_image-548.jpeg', 100, 0),
(752, 'offer_image-545.jpeg', 100, 1),
(753, 'offer_image-546.jpeg', 100, 0),
(754, 'offer_image-547.jpeg', 100, 0),
(765, 'offer_image-558.jpeg', 36, 0),
(773, 'offer_image-565.jpeg', 40, 0),
(775, 'offer_image-567.jpeg', 75, 1),
(776, 'offer_image-568.jpeg', 50, 1),
(777, 'offer_image-569.jpeg', 101, 1),
(778, 'offer_image-570.jpeg', 102, 1),
(779, 'offer_image-571.jpeg', 102, 0),
(780, 'offer_image-572.jpeg', 102, 0),
(781, 'offer_image-573.jpeg', 102, 0),
(782, 'offer_image-574.jpeg', 102, 0),
(783, 'offer_image-575.jpeg', 102, 0),
(784, 'offer_image-576.jpeg', 102, 0),
(785, 'offer_image-577.jpeg', 102, 0),
(786, 'offer_image-578.jpeg', 102, 0),
(787, 'offer_image-579.jpeg', 103, 1),
(788, 'offer_image-580.jpeg', 103, 0),
(789, 'offer_image-581.jpeg', 103, 0),
(790, 'offer_image-582.jpeg', 103, 0),
(791, 'offer_image-583.jpeg', 103, 0),
(792, 'offer_image-584.jpeg', 103, 0),
(793, 'offer_image-585.jpeg', 103, 0),
(794, 'offer_image-586.jpeg', 103, 0),
(795, 'offer_image-587.jpeg', 104, 1),
(796, 'offer_image-588.jpeg', 104, 0),
(797, 'offer_image-589.jpeg', 104, 0),
(798, 'offer_image-590.jpeg', 105, 1),
(799, 'offer_image-591.jpeg', 105, 0),
(800, 'offer_image-592.jpeg', 105, 0),
(801, 'offer_image-593.jpeg', 105, 0),
(802, 'offer_image-594.jpeg', 105, 0),
(803, 'offer_image-595.jpeg', 105, 0),
(804, 'offer_image-596.jpeg', 105, 0),
(805, 'offer_image-597.jpeg', 105, 0),
(806, 'offer_image-598.jpeg', 105, 0),
(1265, 'offer_image-1049.jpeg', 108, 0),
(1264, 'offer_image-1048.jpeg', 108, 0),
(1263, 'offer_image-1047.jpeg', 108, 0),
(1262, 'offer_image-1046.jpeg', 108, 0),
(815, 'offer_image-607.jpeg', 107, 1),
(816, 'offer_image-608.jpeg', 108, 1),
(817, 'offer_image-609.jpeg', 109, 1),
(818, 'offer_image-610.jpeg', 109, 0),
(819, 'offer_image-611.jpeg', 109, 0),
(820, 'offer_image-612.jpeg', 109, 0),
(821, 'offer_image-613.jpeg', 109, 0),
(822, 'offer_image-614.jpeg', 109, 0),
(823, 'offer_image-615.jpeg', 109, 0),
(824, 'offer_image-616.jpeg', 109, 0),
(825, 'offer_image-617.jpeg', 110, 1),
(826, 'offer_image-618.jpeg', 110, 0),
(827, 'offer_image-619.jpeg', 110, 0),
(828, 'offer_image-620.jpeg', 110, 0),
(829, 'offer_image-621.jpeg', 110, 0),
(830, 'offer_image-622.jpeg', 110, 0),
(831, 'offer_image-623.jpeg', 110, 0),
(832, 'offer_image-624.jpeg', 110, 0),
(833, 'offer_image-625.jpeg', 111, 1),
(834, 'offer_image-626.jpeg', 111, 0),
(835, 'offer_image-627.jpeg', 111, 0),
(836, 'offer_image-628.jpeg', 111, 0),
(837, 'offer_image-629.jpeg', 111, 0),
(838, 'offer_image-630.jpeg', 111, 0),
(839, 'offer_image-631.jpeg', 111, 0),
(840, 'offer_image-632.jpeg', 111, 0),
(841, 'offer_image-633.jpeg', 112, 1),
(842, 'offer_image-634.jpeg', 112, 0),
(843, 'offer_image-635.jpeg', 112, 0),
(844, 'offer_image-636.jpeg', 112, 0),
(845, 'offer_image-637.jpeg', 112, 0),
(846, 'offer_image-638.jpeg', 112, 0),
(847, 'offer_image-639.jpeg', 112, 0),
(848, 'offer_image-640.jpeg', 112, 0),
(849, 'offer_image-641.jpeg', 113, 1),
(850, 'offer_image-642.jpeg', 113, 0),
(851, 'offer_image-643.jpeg', 113, 0),
(852, 'offer_image-644.jpeg', 113, 0),
(853, 'offer_image-645.jpeg', 113, 0),
(854, 'offer_image-646.jpeg', 114, 1),
(855, 'offer_image-647.jpeg', 114, 0),
(856, 'offer_image-648.jpeg', 114, 0),
(857, 'offer_image-649.jpeg', 114, 0),
(858, 'offer_image-650.jpeg', 114, 0),
(859, 'offer_image-651.jpeg', 115, 1),
(860, 'offer_image-652.jpeg', 115, 0),
(861, 'offer_image-653.jpeg', 115, 0),
(862, 'offer_image-654.jpeg', 115, 0),
(863, 'offer_image-655.jpeg', 115, 0),
(864, 'offer_image-656.jpeg', 115, 0),
(865, 'offer_image-657.jpeg', 115, 0),
(866, 'offer_image-658.jpeg', 115, 0),
(881, 'offer_image-673.jpeg', 118, 0),
(882, 'offer_image-674.jpeg', 118, 0),
(883, 'offer_image-675.jpeg', 118, 0),
(884, 'offer_image-676.jpeg', 118, 0),
(885, 'offer_image-677.jpeg', 118, 0),
(886, 'offer_image-678.jpeg', 118, 0),
(887, 'offer_image-679.jpeg', 118, 0),
(888, 'offer_image-680.jpeg', 119, 1),
(889, 'offer_image-681.jpeg', 119, 0),
(890, 'offer_image-682.jpeg', 119, 0),
(891, 'offer_image-683.jpeg', 119, 0),
(892, 'offer_image-684.jpeg', 119, 0),
(893, 'offer_image-685.jpeg', 119, 0),
(894, 'offer_image-686.jpeg', 119, 0),
(895, 'offer_image-687.jpeg', 119, 0),
(896, 'offer_image-688.jpeg', 120, 1),
(897, 'offer_image-689.jpeg', 120, 0),
(898, 'offer_image-690.jpeg', 120, 0),
(899, 'offer_image-691.jpeg', 120, 0),
(900, 'offer_image-692.jpeg', 120, 0),
(901, 'offer_image-693.jpeg', 120, 0),
(902, 'offer_image-694.jpeg', 121, 1),
(903, 'offer_image-695.jpeg', 121, 0),
(904, 'offer_image-696.jpeg', 121, 0),
(905, 'offer_image-697.jpeg', 121, 0),
(906, 'offer_image-698.jpeg', 121, 0),
(907, 'offer_image-699.jpeg', 121, 0),
(908, 'offer_image-700.jpeg', 121, 0),
(909, 'offer_image-701.jpeg', 121, 0),
(910, 'offer_image-702.jpeg', 121, 0),
(911, 'offer_image-703.jpeg', 122, 0),
(1088, 'offer_image-875.jpeg', 122, 1),
(913, 'offer_image-705.jpeg', 122, 0),
(914, 'offer_image-706.jpeg', 122, 0),
(915, 'offer_image-707.jpeg', 122, 0),
(916, 'offer_image-708.jpeg', 122, 0),
(917, 'offer_image-709.jpeg', 122, 0),
(918, 'offer_image-710.jpeg', 122, 0),
(919, 'offer_image-711.jpeg', 122, 0),
(920, 'offer_image-712.jpeg', 123, 1),
(921, 'offer_image-713.jpeg', 123, 0),
(922, 'offer_image-714.jpeg', 123, 0),
(923, 'offer_image-715.jpeg', 124, 1),
(924, 'offer_image-716.jpeg', 124, 0),
(925, 'offer_image-717.jpeg', 124, 0),
(926, 'offer_image-718.jpeg', 124, 0),
(927, 'offer_image-719.jpeg', 124, 0),
(928, 'offer_image-720.jpeg', 124, 0),
(929, 'offer_image-721.jpeg', 124, 0),
(930, 'offer_image-722.jpeg', 124, 0),
(931, 'offer_image-723.jpeg', 125, 1),
(932, 'offer_image-724.jpeg', 125, 0),
(933, 'offer_image-725.jpeg', 125, 0),
(934, 'offer_image-726.jpeg', 125, 0),
(935, 'offer_image-727.jpeg', 125, 0),
(936, 'offer_image-728.jpeg', 125, 0),
(937, 'offer_image-729.jpeg', 125, 0),
(945, 'offer_image-737.jpeg', 127, 1),
(946, 'offer_image-738.jpeg', 127, 0),
(947, 'offer_image-739.jpeg', 127, 0),
(948, 'offer_image-740.jpeg', 127, 0),
(949, 'offer_image-741.jpeg', 127, 0),
(950, 'offer_image-742.jpeg', 127, 0),
(951, 'offer_image-743.jpeg', 128, 1),
(952, 'offer_image-744.jpeg', 128, 0),
(953, 'offer_image-745.jpeg', 128, 0),
(954, 'offer_image-746.jpeg', 128, 0),
(955, 'offer_image-747.jpeg', 128, 0),
(956, 'offer_image-748.jpeg', 129, 0),
(957, 'offer_image-749.jpeg', 129, 1),
(958, 'offer_image-750.jpeg', 129, 0),
(959, 'offer_image-751.jpeg', 129, 0),
(960, 'offer_image-752.jpeg', 129, 0),
(961, 'offer_image-753.jpeg', 129, 0),
(962, 'offer_image-754.jpeg', 129, 0),
(963, 'offer_image-755.jpeg', 129, 0),
(964, 'offer_image-756.jpeg', 129, 0),
(965, 'offer_image-757.jpeg', 9, 0),
(966, 'offer_image-758.jpeg', 9, 0),
(967, 'offer_image-759.jpeg', 9, 0),
(968, 'offer_image-760.jpeg', 9, 0),
(969, 'offer_image-761.jpeg', 130, 1),
(970, 'offer_image-762.jpeg', 130, 0),
(971, 'offer_image-763.jpeg', 130, 0),
(972, 'offer_image-764.jpeg', 130, 0),
(973, 'offer_image-765.jpeg', 130, 0),
(974, 'offer_image-766.jpeg', 130, 0),
(975, 'offer_image-767.jpeg', 130, 0),
(976, 'offer_image-768.jpeg', 130, 0),
(977, 'offer_image-769.jpeg', 130, 0),
(978, 'offer_image-770.jpeg', 131, 1),
(979, 'offer_image-771.jpeg', 131, 0),
(980, 'offer_image-13.png', 131, 0),
(981, 'offer_image-772.jpeg', 131, 0),
(982, 'offer_image-773.jpeg', 131, 0),
(983, 'offer_image-774.jpeg', 131, 0),
(984, 'offer_image-775.jpeg', 131, 0),
(985, 'offer_image-776.jpeg', 131, 0),
(986, 'offer_image-777.jpeg', 131, 0),
(989, 'offer_image-779.jpeg', 132, 1),
(990, 'offer_image-780.jpeg', 132, 0),
(991, 'offer_image-781.jpeg', 132, 0),
(992, 'offer_image-782.jpeg', 132, 0),
(993, 'offer_image-783.jpeg', 132, 0),
(994, 'offer_image-784.jpeg', 132, 0),
(995, 'offer_image-785.jpeg', 132, 0),
(996, 'offer_image-786.jpeg', 13, 0),
(997, 'offer_image-787.jpeg', 13, 0),
(998, 'offer_image-788.jpeg', 13, 0),
(1001, 'offer_image-790.jpeg', 133, 1),
(1002, 'offer_image-791.jpeg', 133, 0),
(1003, 'offer_image-792.jpeg', 133, 0),
(1004, 'offer_image-793.jpeg', 133, 0),
(1005, 'offer_image-794.jpeg', 133, 0),
(1006, 'offer_image-795.jpeg', 133, 0),
(1007, 'offer_image-796.jpeg', 133, 0),
(1008, 'offer_image-797.jpeg', 133, 0),
(1009, 'offer_image-798.jpeg', 133, 0),
(1010, 'offer_image-799.jpeg', 85, 0),
(1011, 'offer_image-800.jpeg', 85, 1),
(1013, 'offer_image-802.jpeg', 84, 0),
(1014, 'offer_image-803.jpeg', 49, 0),
(1015, 'offer_image-804.jpeg', 49, 0),
(1016, 'offer_image-805.jpeg', 134, 0),
(1017, 'offer_image-806.jpeg', 134, 0),
(1018, 'offer_image-807.jpeg', 134, 0),
(1019, 'offer_image-808.jpeg', 134, 0),
(1020, 'offer_image-809.jpeg', 134, 0),
(1021, 'offer_image-810.jpeg', 134, 0),
(1022, 'offer_image-811.jpeg', 134, 0),
(1023, 'offer_image-812.jpeg', 134, 1),
(1024, 'offer_image-813.jpeg', 135, 1),
(1025, 'offer_image-814.jpeg', 135, 0),
(1026, 'offer_image-815.jpeg', 135, 0),
(1027, 'offer_image-816.jpeg', 135, 0),
(1028, 'offer_image-817.jpeg', 135, 0),
(1029, 'offer_image-818.jpeg', 136, 1),
(1030, 'offer_image-819.jpeg', 136, 0),
(1031, 'offer_image-820.jpeg', 136, 0),
(1032, 'offer_image-821.jpeg', 136, 0),
(1033, 'offer_image-822.jpeg', 136, 0),
(1034, 'offer_image-823.jpeg', 136, 0),
(1035, 'offer_image-824.jpeg', 136, 0),
(1036, 'offer_image-825.jpeg', 136, 0),
(1037, 'offer_image-826.jpeg', 137, 1),
(1038, 'offer_image-827.jpeg', 137, 0),
(1039, 'offer_image-828.jpeg', 137, 0),
(1040, 'offer_image-829.jpeg', 137, 0),
(1041, 'offer_image-830.jpeg', 137, 0),
(1042, 'offer_image-831.jpeg', 137, 0),
(1043, 'offer_image-832.jpeg', 137, 0),
(1044, 'offer_image-833.jpeg', 137, 0),
(1045, 'offer_image-834.jpeg', 138, 0),
(1046, 'offer_image-835.jpeg', 138, 0),
(1047, 'offer_image-836.jpeg', 138, 0),
(1048, 'offer_image-837.jpeg', 138, 1),
(1049, 'offer_image-838.jpeg', 138, 0),
(1050, 'offer_image-839.jpeg', 138, 0),
(1051, 'offer_image-840.jpeg', 139, 1),
(1052, 'offer_image-841.jpeg', 139, 0),
(1053, 'offer_image-842.jpeg', 139, 0),
(1054, 'offer_image-843.jpeg', 140, 1),
(1055, 'offer_image-844.jpeg', 140, 0),
(1056, 'offer_image-845.jpeg', 140, 0),
(1057, 'offer_image-846.jpeg', 140, 0),
(1067, 'offer_image-856.jpeg', 141, 1),
(1068, 'offer_image-857.jpeg', 141, 0),
(1069, 'offer_image-858.jpeg', 141, 0),
(1072, 'offer_image-859.jpeg', 141, 0),
(1071, 'offer_image-860.jpeg', 141, 0),
(1073, 'offer_image-861.jpeg', 141, 0),
(1074, 'offer_image-862.jpeg', 141, 0),
(1075, 'offer_image-863.jpeg', 95, 0),
(1079, 'offer_image-866.jpeg', 97, 0),
(1080, 'offer_image-867.jpeg', 144, 1),
(1081, 'offer_image-868.jpeg', 144, 0),
(1082, 'offer_image-869.jpeg', 144, 0),
(1083, 'offer_image-870.jpeg', 144, 0),
(1084, 'offer_image-871.jpeg', 144, 0),
(1085, 'offer_image-872.jpeg', 144, 0),
(1098, 'offer_image-885.jpeg', 144, 0),
(1087, 'offer_image-874.jpeg', 144, 0),
(1089, 'offer_image-876.jpeg', 145, 1),
(1090, 'offer_image-877.jpeg', 145, 0),
(1091, 'offer_image-878.jpeg', 145, 0),
(1092, 'offer_image-879.jpeg', 145, 0),
(1093, 'offer_image-880.jpeg', 145, 0),
(1094, 'offer_image-881.jpeg', 145, 0),
(1095, 'offer_image-882.jpeg', 145, 0),
(1096, 'offer_image-883.jpeg', 145, 0),
(1097, 'offer_image-884.jpeg', 145, 0),
(1100, 'offer_image-886.jpeg', 144, 0),
(1101, 'offer_image-887.jpeg', 146, 1),
(1102, 'offer_image-888.jpeg', 146, 0),
(1103, 'offer_image-889.jpeg', 146, 0),
(1104, 'offer_image-890.jpeg', 146, 0),
(1105, 'offer_image-891.jpeg', 146, 0),
(1106, 'offer_image-892.jpeg', 146, 0),
(1107, 'offer_image-893.jpeg', 146, 0),
(1108, 'offer_image-894.jpeg', 146, 0),
(1109, 'offer_image-895.jpeg', 146, 0),
(1110, 'offer_image-896.jpeg', 147, 1),
(1111, 'offer_image-897.jpeg', 147, 0),
(1112, 'offer_image-898.jpeg', 147, 0),
(1113, 'offer_image-899.jpeg', 147, 0),
(1114, 'offer_image-900.jpeg', 147, 0),
(1115, 'offer_image-901.jpeg', 147, 0),
(1116, 'offer_image-902.jpeg', 147, 0),
(1117, 'offer_image-903.jpeg', 147, 0),
(1234, 'offer_image-1020.jpeg', 164, 0),
(1233, 'offer_image-1019.jpeg', 164, 0),
(1232, 'offer_image-1018.jpeg', 164, 0),
(1231, 'offer_image-1017.jpeg', 164, 0),
(1230, 'offer_image-1016.jpeg', 164, 1),
(1240, 'offer_image-1026.jpeg', 163, 0),
(1238, 'offer_image-1024.jpeg', 164, 0),
(1237, 'offer_image-1023.jpeg', 164, 0),
(1236, 'offer_image-1022.jpeg', 164, 0),
(1235, 'offer_image-1021.jpeg', 164, 0),
(1129, 'offer_image-915.jpeg', 150, 1),
(1130, 'offer_image-916.jpeg', 150, 0),
(1131, 'offer_image-917.jpeg', 150, 0),
(1132, 'offer_image-918.jpeg', 150, 0),
(1133, 'offer_image-919.jpeg', 150, 0),
(1134, 'offer_image-920.jpeg', 151, 0),
(1135, 'offer_image-921.jpeg', 151, 0),
(1136, 'offer_image-922.jpeg', 151, 0),
(1137, 'offer_image-923.jpeg', 151, 0),
(1138, 'offer_image-924.jpeg', 151, 0),
(1139, 'offer_image-925.jpeg', 151, 0),
(1141, 'offer_image-927.jpeg', 151, 1),
(1142, 'offer_image-928.jpeg', 24, 1),
(1143, 'offer_image-929.jpeg', 24, 0),
(1145, 'offer_image-931.jpeg', 128, 0),
(1146, 'offer_image-932.jpeg', 49, 0),
(1150, 'offer_image-936.jpeg', 84, 0),
(1151, 'offer_image-937.jpeg', 96, 1),
(1152, 'offer_image-938.jpeg', 96, 0),
(1163, 'offer_image-949.jpeg', 155, 1),
(1164, 'offer_image-950.jpeg', 155, 0),
(1165, 'offer_image-951.jpeg', 155, 0),
(1166, 'offer_image-952.jpeg', 155, 0),
(1167, 'offer_image-953.jpeg', 155, 0),
(1168, 'offer_image-954.jpeg', 155, 0),
(1169, 'offer_image-955.jpeg', 156, 1),
(1170, 'offer_image-956.jpeg', 156, 0),
(1171, 'offer_image-957.jpeg', 156, 0),
(1172, 'offer_image-958.jpeg', 156, 0),
(1173, 'offer_image-959.jpeg', 156, 0),
(1174, 'offer_image-960.jpeg', 157, 0),
(1175, 'offer_image-961.jpeg', 157, 0),
(1176, 'offer_image-962.jpeg', 157, 0),
(1178, 'offer_image-964.jpeg', 157, 1),
(1180, 'offer_image-966.jpeg', 158, 1),
(1181, 'offer_image-967.jpeg', 158, 0),
(1182, 'offer_image-968.jpeg', 158, 0),
(1183, 'offer_image-969.jpeg', 158, 0),
(1184, 'offer_image-970.jpeg', 158, 0),
(1185, 'offer_image-971.jpeg', 158, 0),
(1186, 'offer_image-972.jpeg', 158, 0),
(1187, 'offer_image-973.jpeg', 158, 0),
(1188, 'offer_image-974.jpeg', 158, 0),
(1189, 'offer_image-975.jpeg', 159, 1),
(1190, 'offer_image-976.jpeg', 159, 0),
(1191, 'offer_image-977.jpeg', 159, 0),
(1192, 'offer_image-978.jpeg', 159, 0),
(1193, 'offer_image-979.jpeg', 159, 0),
(1195, 'offer_image-981.jpeg', 160, 1),
(1196, 'offer_image-982.jpeg', 160, 0),
(1197, 'offer_image-983.jpeg', 160, 0),
(1198, 'offer_image-984.jpeg', 160, 0),
(1199, 'offer_image-985.jpeg', 160, 0),
(1200, 'offer_image-986.jpeg', 160, 0),
(1201, 'offer_image-987.jpeg', 160, 0),
(1202, 'offer_image-988.jpeg', 160, 0),
(1203, 'offer_image-989.jpeg', 161, 1),
(1204, 'offer_image-990.jpeg', 161, 0),
(1205, 'offer_image-991.jpeg', 161, 0),
(1206, 'offer_image-992.jpeg', 161, 0),
(1207, 'offer_image-993.jpeg', 161, 0),
(1208, 'offer_image-995.jpeg', 161, 0),
(1209, 'offer_image-996.jpeg', 161, 0),
(1210, 'offer_image-994.jpeg', 161, 0),
(1211, 'offer_image-997.jpeg', 161, 0),
(1212, 'offer_image-998.jpeg', 162, 1),
(1213, 'offer_image-999.jpeg', 162, 0),
(1214, 'offer_image-1000.jpeg', 162, 0),
(1215, 'offer_image-1001.jpeg', 162, 0),
(1216, 'offer_image-1002.jpeg', 162, 0),
(1217, 'offer_image-1003.jpeg', 162, 0),
(1218, 'offer_image-1004.jpeg', 162, 0),
(1219, 'offer_image-1005.jpeg', 162, 0),
(1220, 'offer_image-1006.jpeg', 162, 0),
(1221, 'offer_image-1007.jpeg', 163, 1),
(1222, 'offer_image-1008.jpeg', 163, 0),
(1223, 'offer_image-1009.jpeg', 163, 0),
(1224, 'offer_image-1010.jpeg', 163, 0),
(1239, 'offer_image-1025.jpeg', 163, 0),
(1227, 'offer_image-1013.jpeg', 163, 0),
(1228, 'offer_image-1014.jpeg', 163, 0),
(1229, 'offer_image-1015.jpeg', 163, 0),
(1241, 'offer_image-1027.jpeg', 165, 1),
(1242, 'offer_image-1028.jpeg', 165, 0),
(1243, 'offer_image-1029.jpeg', 165, 0),
(1244, 'offer_image-1030.jpeg', 165, 0),
(1245, 'offer_image-1031.jpeg', 166, 1),
(1246, 'offer_image-1032.jpeg', 166, 0),
(1247, 'offer_image-1033.jpeg', 166, 0),
(1248, 'offer_image-1034.jpeg', 166, 0),
(1249, 'offer_image-1035.jpeg', 166, 0),
(1250, 'offer_image-1036.jpeg', 166, 0),
(1251, 'offer_image-1037.jpeg', 167, 1),
(1252, 'offer_image-1038.jpeg', 167, 0),
(1253, 'offer_image-1039.jpeg', 167, 0),
(1254, 'offer_image-1040.jpeg', 167, 0),
(1255, 'offer_image-1041.jpeg', 167, 0),
(1256, 'offer_image-1042.jpeg', 167, 0),
(1257, 'offer_image-1043.jpeg', 167, 0),
(1258, 'offer_image-1044.jpeg', 167, 0),
(1259, 'offer_image-1045.jpeg', 167, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `offerCharacteristics`
--

CREATE TABLE `offerCharacteristics` (
  `id` int(11) NOT NULL,
  `value` int(128) NOT NULL,
  `offer_id` int(11) NOT NULL,
  `characteristic_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `offerCharacteristics`
--

INSERT INTO `offerCharacteristics` (`id`, `value`, `offer_id`, `characteristic_id`) VALUES
(2563, 14, 155, 32),
(1939, 25, 11, 32),
(1938, 800, 11, 30),
(1796, 275, 13, 32),
(1795, 700, 13, 30),
(2583, 250, 9, 32),
(1937, 10, 17, 32),
(1936, 500, 17, 30),
(1925, 0, 18, 54),
(1924, 0, 18, 48),
(1923, 2, 18, 44),
(1922, 19, 18, 42),
(1921, 35, 18, 41),
(1920, 50, 18, 40),
(1919, 1, 18, 38),
(1918, 1, 18, 37),
(1917, 22000, 18, 34),
(2670, 42, 19, 32),
(2669, 400, 19, 30),
(1941, 10, 20, 32),
(1940, 12000, 20, 29),
(1943, 10, 21, 32),
(1942, 11000, 21, 29),
(1945, 35, 22, 32),
(1944, 400, 22, 30),
(1954, 0, 23, 57),
(1953, 0, 23, 48),
(1952, 2015, 23, 45),
(1951, 4, 23, 44),
(1950, 15, 23, 42),
(1949, 120, 23, 41),
(1948, 200, 23, 40),
(1947, 2, 23, 38),
(1946, 90000, 23, 34),
(2267, 0, 24, 54),
(2266, 0, 24, 48),
(2265, 1990, 24, 45),
(2264, 2, 24, 44),
(2263, 15, 24, 42),
(2262, 105, 24, 41),
(2261, 200, 24, 40),
(2260, 1, 24, 38),
(2259, 25000, 24, 34),
(1914, 500, 33, 32),
(1913, 300, 33, 30),
(633, 100, 34, 32),
(632, 600, 34, 30),
(429, 1000, 35, 30),
(430, 20, 35, 32),
(2672, 500, 36, 32),
(2671, 600, 36, 30),
(450, 0, 37, 54),
(449, 0, 37, 48),
(448, 1990, 37, 45),
(447, 3, 37, 44),
(446, 70, 37, 42),
(445, 45, 37, 41),
(444, 70, 37, 40),
(443, 1, 37, 38),
(442, 45000, 37, 34),
(454, 8, 38, 32),
(453, 12500, 38, 29),
(1823, 0, 39, 59),
(1822, 0, 39, 48),
(1821, 2014, 39, 45),
(1820, 4, 39, 44),
(1819, 33, 39, 42),
(1818, 80, 39, 41),
(1817, 180, 39, 40),
(1816, 2, 39, 38),
(1815, 23000, 39, 34),
(2674, 50, 40, 32),
(2673, 1000, 40, 30),
(1956, 25, 41, 32),
(1955, 20000, 41, 29),
(1958, 29, 42, 32),
(1957, 1000, 42, 30),
(1347, 0, 43, 54),
(1346, 0, 43, 48),
(1345, 1990, 43, 45),
(1344, 3, 43, 44),
(1343, 22, 43, 42),
(1342, 50, 43, 41),
(1341, 75, 43, 40),
(1340, 1, 43, 38),
(1339, 22000, 43, 34),
(2753, 0, 44, 51),
(2752, 0, 44, 48),
(2751, 2014, 44, 45),
(2750, 4, 44, 44),
(2749, 5, 44, 42),
(2748, 70, 44, 41),
(2747, 109, 44, 40),
(2746, 2, 44, 38),
(2745, 87000, 44, 34),
(1967, 0, 45, 51),
(1966, 0, 45, 48),
(1965, 2010, 45, 45),
(1964, 7, 45, 44),
(1963, 65, 45, 42),
(1962, 102, 45, 41),
(1961, 172, 45, 40),
(1960, 2, 45, 38),
(1959, 600000, 45, 34),
(1513, 0, 46, 57),
(1512, 0, 46, 48),
(1511, 2015, 46, 45),
(1510, 5, 46, 44),
(1509, 10, 46, 42),
(1508, 90, 46, 41),
(1507, 142, 46, 40),
(1506, 2, 46, 38),
(1505, 35000, 46, 34),
(2249, 0, 47, 54),
(2248, 0, 47, 48),
(2247, 1990, 47, 45),
(2246, 3, 47, 44),
(2245, 27, 47, 42),
(2244, 35, 47, 41),
(2243, 50, 47, 40),
(2242, 1, 47, 38),
(2241, 32000, 47, 34),
(1383, 0, 48, 54),
(1382, 0, 48, 48),
(1381, 2001, 48, 45),
(1380, 3, 48, 44),
(1379, 27, 48, 42),
(1378, 90, 48, 41),
(1377, 120, 48, 40),
(1376, 1, 48, 38),
(1375, 22000, 48, 34),
(2303, 0, 49, 52),
(2302, 0, 49, 48),
(2301, 2014, 49, 45),
(2300, 4, 49, 44),
(2299, 54, 49, 42),
(2298, 90, 49, 41),
(2297, 160, 49, 40),
(2296, 2, 49, 38),
(2295, 59000, 49, 34),
(2682, 0, 50, 50),
(2681, 0, 50, 48),
(2680, 5, 50, 44),
(2679, 12, 50, 42),
(2678, 91, 50, 41),
(2677, 135, 50, 40),
(2676, 2, 50, 38),
(2675, 90000, 50, 34),
(2819, 0, 51, 59),
(2818, 0, 51, 48),
(2817, 2015, 51, 45),
(2816, 5, 51, 44),
(2815, 20, 51, 42),
(2814, 108, 51, 41),
(2813, 213, 51, 40),
(2812, 2, 51, 38),
(2811, 70000, 51, 34),
(2258, 0, 52, 54),
(2257, 0, 52, 48),
(2256, 2000, 52, 45),
(2255, 4, 52, 44),
(2254, 100, 52, 42),
(2253, 60, 52, 41),
(2252, 85, 52, 40),
(2251, 2, 52, 38),
(2250, 12500, 52, 34),
(1368, 80, 53, 32),
(1367, 700, 53, 30),
(562, 30000, 54, 29),
(563, 50, 54, 32),
(564, 600, 55, 30),
(565, 40, 55, 32),
(566, 600, 56, 30),
(567, 90, 56, 32),
(568, 800, 57, 30),
(569, 23, 57, 32),
(570, 1000, 58, 30),
(571, 12, 58, 32),
(572, 1000, 59, 30),
(573, 17, 59, 32),
(574, 1000, 60, 30),
(575, 20, 60, 32),
(2686, 75, 66, 32),
(2685, 750, 66, 30),
(1515, 30, 65, 32),
(1514, 20000, 65, 29),
(2684, 370, 64, 32),
(2683, 700, 64, 30),
(2688, 50, 67, 32),
(2687, 15000, 67, 29),
(2690, 25, 68, 32),
(2689, 600, 68, 30),
(2692, 20, 69, 32),
(2691, 800, 69, 30),
(2694, 75, 70, 32),
(2693, 800, 70, 30),
(2696, 7, 71, 32),
(2695, 700, 71, 30),
(2698, 25, 72, 32),
(2697, 600, 72, 30),
(973, 17, 73, 32),
(972, 12000, 73, 29),
(1517, 50, 74, 32),
(1516, 700, 74, 30),
(1519, 9, 75, 32),
(1518, 10000, 75, 29),
(1521, 15, 76, 32),
(1520, 1000, 76, 30),
(622, 600, 77, 30),
(623, 40, 77, 32),
(624, 600, 78, 30),
(625, 25, 78, 32),
(626, 500, 79, 30),
(627, 90, 79, 32),
(1523, 18, 80, 32),
(1522, 29000, 80, 29),
(1525, 50, 81, 32),
(1524, 20000, 81, 29),
(977, 100, 82, 32),
(976, 600, 82, 30),
(2901, 0, 83, 17),
(2900, 0, 83, 15),
(2899, 2005, 83, 12),
(2898, 12, 83, 11),
(2897, 300, 83, 9),
(2896, 660, 83, 8),
(2895, 2, 83, 6),
(2894, 190000, 83, 2),
(2309, 545, 84, 32),
(2308, 300, 84, 30),
(1846, 800, 85, 32),
(1845, 300, 85, 30),
(2700, 75, 86, 32),
(2699, 1000, 86, 30),
(1996, 65, 87, 32),
(1995, 700, 87, 30),
(1468, 280, 88, 32),
(1467, 300, 88, 30),
(2582, 300, 9, 30),
(995, 3500, 90, 32),
(994, 500, 90, 30),
(1457, 0, 91, 57),
(1456, 0, 91, 48),
(1455, 2015, 91, 45),
(1454, 4, 91, 44),
(1453, 8, 91, 42),
(1452, 80, 91, 41),
(1451, 160, 91, 40),
(1450, 2, 91, 38),
(1449, 58000, 91, 34),
(1239, 0, 92, 55),
(1238, 0, 92, 48),
(1237, 3, 92, 44),
(1236, 140, 92, 42),
(1235, 100, 92, 40),
(1234, 1, 92, 38),
(1233, 70000, 92, 34),
(1252, 800, 93, 32),
(1251, 200, 93, 30),
(2709, 0, 95, 51),
(2708, 0, 95, 48),
(2707, 2012, 95, 45),
(2706, 3, 95, 44),
(2705, 11, 95, 42),
(2704, 70, 95, 41),
(2703, 140, 95, 40),
(2702, 2, 95, 38),
(2701, 48000, 95, 34),
(2711, 50, 96, 32),
(2710, 250, 96, 30),
(2114, 0, 97, 51),
(2113, 0, 97, 48),
(2112, 2014, 97, 45),
(2111, 3, 97, 44),
(2110, 7, 97, 42),
(2109, 140, 97, 40),
(2108, 2, 97, 38),
(2107, 45000, 97, 34),
(2138, 0, 116, 54),
(2137, 0, 116, 48),
(2136, 4, 116, 44),
(2135, 16, 116, 42),
(2134, 60, 116, 41),
(2133, 110, 116, 40),
(2132, 1, 116, 38),
(1630, 5, 117, 44),
(1629, 40, 117, 42),
(1628, 80, 117, 41),
(1627, 120, 117, 40),
(1626, 1, 117, 38),
(1625, 20000, 117, 34),
(2131, 55000, 116, 34),
(1547, 0, 100, 18),
(1546, 0, 100, 15),
(1545, 2010, 100, 12),
(1544, 8, 100, 11),
(1543, 412, 100, 8),
(1542, 2, 100, 6),
(1541, 360000, 100, 2),
(2863, 85, 101, 32),
(2862, 7500, 101, 30),
(2867, 37, 102, 32),
(2866, 7000, 102, 30),
(1430, 250000, 103, 34),
(1431, 2, 103, 38),
(1432, 200, 103, 40),
(1433, 22, 103, 42),
(1434, 6, 103, 44),
(1435, 2007, 103, 45),
(1436, 0, 103, 48),
(1437, 0, 103, 51),
(2647, 400, 104, 32),
(2646, 120, 104, 30),
(2859, 5000, 105, 32),
(2858, 3000, 105, 30),
(1975, 20, 107, 32),
(1974, 100, 107, 30),
(2873, 44, 108, 32),
(2872, 5500, 108, 30),
(1556, 75000, 109, 34),
(1557, 2, 109, 38),
(1558, 120, 109, 40),
(1559, 13, 109, 42),
(1560, 4, 109, 44),
(1561, 2015, 109, 45),
(1562, 0, 109, 48),
(1563, 0, 109, 57),
(1688, 0, 110, 51),
(1687, 0, 110, 48),
(1686, 2007, 110, 45),
(1685, 5, 110, 44),
(1684, 25, 110, 42),
(1683, 80, 110, 41),
(1682, 160, 110, 40),
(1681, 2, 110, 38),
(1680, 220000, 110, 34),
(1581, 180000, 111, 34),
(1582, 2, 111, 38),
(1583, 235, 111, 40),
(1584, 155, 111, 41),
(1585, 8, 111, 42),
(1586, 5, 111, 44),
(1587, 2010, 111, 45),
(1588, 0, 111, 48),
(1589, 0, 111, 51),
(1590, 160000, 112, 34),
(1591, 3, 112, 38),
(1592, 300, 112, 40),
(1593, 120, 112, 41),
(1594, 21, 112, 42),
(1595, 6, 112, 44),
(1596, 2012, 112, 45),
(1597, 0, 112, 48),
(1598, 0, 112, 51),
(2877, 20, 113, 32),
(2876, 8000, 113, 30),
(2857, 0, 114, 18),
(2856, 0, 114, 15),
(2855, 2010, 114, 12),
(2854, 6, 114, 11),
(2853, 213, 114, 8),
(2852, 2, 114, 6),
(2851, 80000, 114, 2),
(1610, 360000, 115, 2),
(1611, 2, 115, 6),
(1612, 800, 115, 8),
(1613, 12, 115, 11),
(1614, 2014, 115, 12),
(1615, 0, 115, 15),
(1616, 0, 115, 17),
(1631, 0, 117, 48),
(1632, 0, 117, 54),
(1633, 20000, 118, 29),
(1634, 20, 118, 32),
(1738, 0, 119, 17),
(1737, 0, 119, 15),
(1736, 2011, 119, 12),
(1735, 22, 119, 11),
(1734, 930, 119, 8),
(1733, 2, 119, 6),
(1732, 590000, 119, 2),
(1656, 100000, 120, 34),
(1657, 2, 120, 38),
(1658, 132, 120, 40),
(1659, 70, 120, 41),
(1660, 25, 120, 42),
(1661, 5, 120, 44),
(1662, 2011, 120, 45),
(1663, 0, 120, 48),
(1664, 0, 120, 51),
(1665, 120000, 121, 34),
(1666, 2, 121, 38),
(1667, 200, 121, 40),
(1668, 100, 121, 41),
(1669, 10, 121, 42),
(1670, 5, 121, 44),
(1671, 2015, 121, 45),
(1672, 0, 121, 48),
(1673, 0, 121, 51),
(2157, 80, 122, 32),
(2156, 600, 122, 30),
(1676, 3000, 123, 30),
(1677, 525, 123, 32),
(1971, 195, 124, 32),
(1970, 15000, 124, 29),
(2720, 0, 125, 54),
(2719, 0, 125, 48),
(2718, 1990, 125, 45),
(2717, 2, 125, 44),
(2716, 20, 125, 42),
(2715, 25, 125, 41),
(2714, 40, 125, 40),
(2713, 1, 125, 38),
(2712, 17000, 125, 34),
(1707, 350000, 127, 2),
(1708, 3, 127, 6),
(1709, 554, 127, 8),
(1710, 20, 127, 11),
(1711, 2015, 127, 12),
(1712, 0, 127, 15),
(1713, 0, 127, 26),
(2294, 0, 128, 54),
(2293, 0, 128, 48),
(2292, 2000, 128, 45),
(2291, 3, 128, 44),
(2290, 100, 128, 42),
(2289, 45, 128, 41),
(2288, 90, 128, 40),
(2287, 2, 128, 38),
(2286, 20000, 128, 34),
(2276, 0, 129, 54),
(2275, 0, 129, 48),
(2274, 2000, 129, 45),
(2273, 2, 129, 44),
(2272, 60, 129, 42),
(2271, 25, 129, 41),
(2270, 60, 129, 40),
(2269, 1, 129, 38),
(2268, 12000, 129, 34),
(1751, 2500, 130, 3),
(1752, 41, 130, 5),
(1753, 47, 130, 6),
(1754, 200, 130, 8),
(1755, 120, 130, 9),
(1756, 3, 130, 11),
(1757, 2014, 130, 12),
(1758, 0, 130, 14),
(1759, 0, 130, 24),
(1760, 1500, 131, 3),
(1761, 5, 131, 5),
(1762, 47, 131, 6),
(1763, 90, 131, 8),
(1764, 45, 131, 9),
(1765, 1, 131, 11),
(1766, 2014, 131, 12),
(1767, 0, 131, 14),
(1768, 0, 131, 24),
(1777, 300, 132, 30),
(1778, 100, 132, 32),
(2532, 0, 133, 51),
(2531, 0, 133, 48),
(2530, 2013, 133, 45),
(2529, 4, 133, 44),
(2528, 13, 133, 42),
(2527, 120, 133, 41),
(2526, 200, 133, 40),
(2525, 2, 133, 38),
(2524, 60000, 133, 34),
(2738, 0, 134, 54),
(2737, 0, 134, 48),
(2736, 2000, 134, 45),
(2735, 3, 134, 44),
(2734, 400, 134, 42),
(2733, 50, 134, 41),
(2732, 80, 134, 40),
(2731, 1, 134, 38),
(2730, 48000, 134, 34),
(1969, 200, 135, 32),
(1968, 200, 135, 30),
(1882, 250000, 136, 2),
(1883, 2, 136, 6),
(1884, 310, 136, 8),
(1885, 120, 136, 9),
(1886, 12, 136, 11),
(1887, 2010, 136, 12),
(1888, 0, 136, 15),
(1889, 0, 136, 18),
(2843, 20, 137, 32),
(2842, 8000, 137, 30),
(2740, 75, 138, 32),
(2739, 7500, 138, 29),
(1909, 300, 139, 30),
(1910, 101, 139, 32),
(1911, 200, 140, 30),
(1912, 157, 140, 32),
(1997, 21000, 141, 29),
(1998, 112, 141, 32),
(2191, 0, 144, 21),
(2190, 0, 144, 15),
(2189, 5, 144, 11),
(2188, 160, 144, 8),
(2187, 2, 144, 6),
(2186, 50000, 144, 2),
(2185, 0, 145, 15),
(2184, 5, 145, 11),
(2183, 160, 145, 8),
(2182, 2, 145, 6),
(2181, 55000, 145, 2),
(2192, 40000, 146, 2),
(2193, 2, 146, 6),
(2194, 100, 146, 8),
(2195, 4, 146, 11),
(2196, 0, 146, 15),
(2197, 40000, 147, 2),
(2198, 2, 147, 6),
(2199, 200, 147, 8),
(2200, 6, 147, 11),
(2201, 2015, 147, 12),
(2202, 0, 147, 15),
(2203, 0, 147, 26),
(2204, 20, 147, 42),
(2827, 20, 164, 32),
(2826, 6000, 164, 30),
(2666, 10, 165, 32),
(2665, 1000, 165, 30),
(2209, 1200, 150, 30),
(2210, 14, 150, 42),
(2214, 14, 151, 42),
(2213, 24000, 151, 29),
(2562, 3000, 155, 30),
(2742, 200, 156, 32),
(2741, 500, 156, 30),
(2569, 18, 157, 32),
(2568, 800, 157, 30),
(2596, 100, 158, 32),
(2595, 25000, 158, 29),
(2586, 45000, 159, 34),
(2587, 2, 159, 38),
(2588, 100, 159, 40),
(2589, 70, 159, 41),
(2590, 6, 159, 42),
(2591, 4, 159, 44),
(2592, 2015, 159, 45),
(2593, 0, 159, 48),
(2594, 0, 159, 51),
(2645, 0, 160, 56),
(2644, 0, 160, 48),
(2643, 2015, 160, 45),
(2642, 6, 160, 44),
(2641, 15, 160, 42),
(2640, 152, 160, 41),
(2639, 190, 160, 40),
(2638, 2, 160, 38),
(2637, 90000, 160, 34),
(2623, 0, 161, 50),
(2622, 0, 161, 48),
(2621, 2014, 161, 45),
(2620, 4, 161, 44),
(2619, 12, 161, 42),
(2618, 53, 161, 41),
(2617, 90, 161, 40),
(2616, 2, 161, 38),
(2615, 55000, 161, 34),
(2835, 25, 162, 32),
(2834, 5500, 162, 30),
(2831, 25, 163, 32),
(2830, 6000, 163, 30),
(2839, 5, 166, 32),
(2838, 8000, 166, 30),
(2743, 33000, 167, 29),
(2744, 21, 167, 32);

-- --------------------------------------------------------

--
-- Структура таблицы `offers`
--

CREATE TABLE `offers` (
  `id` int(11) NOT NULL,
  `title` varchar(2048) NOT NULL,
  `description` varchar(15360) NOT NULL,
  `location` varchar(2048) NOT NULL,
  `video` varchar(2048) NOT NULL,
  `category_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `offers`
--

INSERT INTO `offers` (`id`, `title`, `description`, `location`, `video`, `category_id`, `owner_id`) VALUES
(9, 'Участок под коттеджный Эко-городок, санаторий или под элитное имение в Карпатах, Верховина', 'Будем рады помочь вам поселиться в экологически чистых и сказочных Карпатах! Неповторимый участок 24 га (2400 соток), можно рассмотреть продажу частями (125, 275, 550, 650, 800 соток) под лечебный центр, Эко-городок, санаторий или под элитное имение, возле горнолыжного трамплина, вокруг волшебные горы и девственный лес. Благодаря доступной цене и уникальному шансу, Вы получите частицу райского места в самом сердце Карпат, позволит реализовать фантастические мечты современного качества жизни в экологическом месте, на лоне природы, с доступом к чистой живой воде, целебному карпатскому воздуху, с возможностью выращивать на собственном участке овощи и фрукты! Дополнительные преимущества этого района – уникальный природный потенциал: минеральная вода, родники, река, дешевое электричество.Это удивительное и фантастическое место в Верховине, находится в самом центре Карпат и считается столицей Гуцульщины. Преимущества: 1) Вы можете реализовать фантастические мечты в экологическом месте, на лоне природы и получить частицу райского места планеты в самом сердце Карпат! 2) Уникальный природный потенциал: минеральная вода, родники, река, дешевое электричество. 3) Участок находится на уровне лучших зарубежных курортов! Известны Семь чудес Верховинщины: обсерватория на горе Поп Иван, геологическая памятка природы Писаный Камень, высокогорное озеро Маричейка, высокие скалы Шпицы, церковь Рождества Богородицы (с.Криворовня), Кладовые Довбуша на г.Синицы, скалы в парке Венгерское. Это место притягивает духовников и монахов своей вселенской тишиной и отсутствием суеты. Ночи здесь дарят покой и умиротворение. Утро будит пением птиц. Когда вы распахнете свое окно на рассвете, вдохнете свежий воздух и энергию пробуждающейся природы, только тогда по-настоящему почувствуете себя живым. Цена: от 300у.е. до 2000у.е./сотка, зависит от размера и месторасположения участка!', 'Верховина, Ивано-Франковская область, Украина', 'vkZr3RXa8Q', 31, 2),
(18, 'Верховина, центр, дом на 19-сотках земли с непревзойденным видом на горы', 'Верховина - гуцульская столица, центр, дом 50м2 на 19-сотках земли с непревзойденным видом на горы. Свет и вода имеются, до центра 5-минут пешком, до горнолыжного трамплина в Верховине 2-км в одну сторону и до горнолыжного курорта в Ильцах 2км в другую, развитая инфраструктура! Вокруг тишина и покой, которыми можно насладится и отдохнуть от повседневной суеты, войти сказочную атмосферу и побыть сам на сам с природой!', 'Верховина, Ивано-Франковская область, Украина', 'JjE6ULAT8_M', 25, 2),
(155, 'Продам земельный участок 14 соток, под строительство Отеля, Ресторана', 'Ивано-Франковская область, пгт. Ворохта, улица Данила Галицького. Ровный фасадный земельный участок 14 соток, под строительство Отеля, Ресторана, Усадьбы, Фасад главной улицы. Живописный вид на горы. 25 км от Буковеля. Документы готовы. \nВорохта — расположена в верховьях реки Прут, на северных склонах Лесистых Карпат, близ Яблоницкого перевала (850 м). На курорте Ворохты располагается центр подготовки украинских спортсменов по прыжкам с трамплина, биатлону и лыжным гонкам. Ворохта, является одним из основных центров туризма Ивано-Франковской области, как летом, так и зимой. Для почитателей лыжного спорта, здесь есть несколько подъемников. Возле базы «Авангард» — 300-метровый бугельный и 2-километровый кресельный. На р.Маковка — 250-метровый подъемник-бугель. Во время зимнего сезона устанавливают еще два 100-метровых подъемника. Неподалеку от поселка расположена спортивно-туристическая база «Заросляк», откуда начинается маршрут восхождения на высочайшую вершину Украины — на г. Говерла.\n', 'Украина, Ивано-Франковская область, пгт. Ворохта, улица Данила Галицького', '', 34, 2),
(139, 'Участок 1-га на трассе М07, рядом крупное месторождение янтаря', 'Участок 1,095 га относится к Белокоровичскому сельскому совету, Олевского района, Житомирской обл. Размеры: 103х52 м.\nУчасток выходит на международную трассу М07 (Е373) Люблин - Киев, удалённость: до Люблина - 399 км, до Киева - 185 км, до границы с Польшей - 300 км, до границы с Беларусью - 60 км. До ж/д станции Новые Белокоровичи 6 км.\nПо границе участка проходит высоковольтная ЛЭП.\nПоблизости находятся: Белокоровичское лесное хозяйство (выращивание, переработка леса, изготовление упаковочной продукции и шпал), крупное месторождение янтаря, месторождение кварцитовидных песчаников, гранитный карьер, торфобрикетный завод (с. Бучманы), ведётся добыча известняка и торфа.\nтел.: +38-096-768-83-76', 'Белокоровичи, Олевский район, Житомирская область, Украина', 'e78TBx42DMg', 34, 2),
(17, 'Земельные участки от 10-200 соток для объектов отдыха и здоровья в Верховине', 'Верховина, прис.Грабовець, предлагаю множество участков от 10 соток до 2 га! Прекрасный вид на горные хребты, рядом асфальтированная дорога Верховина - Буковель - Ивано-Франковск, свет и вода присутствуют.', 'Верховина, Ивано-Франковская область, Украина', 'dkRODLTdHPM', 33, 2),
(11, 'Участок 25 соток в с. Бережница, Прикарпаття', 'Общая площадь участка 25 соток. Государственные акты: для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений 8-соток, для ведения личного крестьянского хозяйства 17 соток. Возле центральной дороги. Свет, вода на участке. Рядом протекает ручей. До районного центра- 7км. До областного центра-120км. До Буковеля - 60км.', 'с. Бережниця, Верховинского району, Ивано-Франковской области, Украина', '3JNBCBma1Gg', 31, 2),
(13, 'Земельный участок 275 соток для объектов отдыха и здоровья в Карпатах', 'Участок в Верховине, Замагора, 275 соток, находится рядом с горнолыжным трамплином и национального парка! На участке есть вода, свет, строения. На этой территории, от прекрасного вида первозданной природы захватывает дыхание: грациозные деревья с вечнозелеными лохматыми ветвями дремлют в утренней дымке, солнце радужно освещает застывшие в глубоком раздумье горы. Вокруг тишина и покой, которыми можно насладится и отдохнуть от повседневной суеты, войти сказочную атмосферу и побыть сам на сам с природой!', 'Верховина, Ивано-Франковская область, Украина', 'mz_Y7bikKac', 34, 2),
(19, 'Очаровательный участок 42-сотки в Карпатах, Кривополье', 'Кривополье, прис.Воловая, 42-сотки земли (25-соток под застройку, 17-соток ОСГ), свет, вода, река, от дороги к участку 20-метров, вид на горы, замечательные соседи. На этой территории, от прекрасного вида первоначальной природы захватывает дух! Вокруг тишина и покой, которыми можно насладиться и отдохнуть от повседневной суеты, войти сказочную атмосферу и побыть наедине с природой! Здесь также будет, где разгуляться заядлому грибнику. Есть река, которую при желании можно превратить в пруд с кристально чистой водой, где потом с восторгом созерцать как собственное отражение, так и горную золотую рыбку – форель, которая непременно исполнит Ваше желание. Возможен торг!', 'Воловая, Ивано-Франковская область, Украина', 's1zTw5A8r8k', 33, 2),
(20, 'Участок 10 соток под строительство в Верховина, Карпаты', 'Верховина, центр, 10-соток прекрасного ровного участка, свет и вода есть, маленький домик на участке, хорошее место для спокойной жизни, приятные соседи, 5-минут пешком до центра. Возможно под коммерцию. Удачный выбор места и дома позволяет реализовать немалые преимущества жизни в Карпатах - жизнь в здоровой обстановке, на лоне природы, чистая вода, не загрязнен воздух, на личной территории, с возможностью при желании самостоятельно выращивать овощи и фрукты для своей семьи. Верховина порадует своей красотой природных горных ландшафтов и является лидером карпатского края, на территории находится более 100 источников минеральных вод. На этой территории, от прекрасного вида первоначальной природы захватывает дыхание: грациозные дерева с вечнозелеными лохматыми ветвями дремлют в утренней дымке, солнце радужно освещает застывшую в глубокой задумчивости гору. Вокруг тишина и покой, которыми можно насладиться и отдохнуть от повседневной суеты, войти сказочную атмосферу и побыть наедине с природой!', 'Ивано-Франковская область, пгт. Верховина', 'ddSAzKup2SU', 33, 2),
(21, 'Участок 10 соток в прекрасном тихом месте Карпат, Верховина', 'Один из своеобразных горнолыжных курортов - это Верховина, находится на высоте 620м над уровнем моря, склонившееся между горных хребтов, словно затерянный в часе- это начало Черногорского хребта в самом сердце Карпат. Центр, 10 соток земли в прекрасном тихом месте, с одной стороны граничит с рекой Черемош, что делает это место неповторимым и незабываемым и другой стороны 100 метров живописный лес. Подъезд хороший, свет и вода присутствуют, 50 метров дороги нужно подлатать немного.\nВерховинский район- известен в Украине еще и своими минеральными водами, здесь более 100 минеральных источников с целебной водой! Верховинский район, считается лечебно-оздоровительным центром Прикарпатья. В районе развит и зеленый туризм. Здесь практически десятки усадеб и комплексов для отдыха. Снег в этом районе выпадает где-то примерно в середине декабря и держится примерно до середины марта. На территории горнолыжных спусков есть два подъемника (Верховинский район) - один в Верховине, другой в ближнем с. Ильци (примерно 5 км от Верховины - в сторону как ехать на Ворохту). С расслабляющего отдыха, здесь есть практически все: катание на гуцульских лошадях и квадроциклах по своей природе лучшим в Карпатах местам, пейнтбол, страйкбол, еще это лучшее место для профессионалов и любителей рафтинга. Для поклонников пешеходных прогулок, здесь около 40 маршрутов, прекрасные места для сбора белых грибов, ягод, лекарственных трав и корней.', 'Ивано-Франковская область, пгт. Верховина', 'njSdddUTI6s', 33, 2),
(22, 'Сказочный земельный участок 35 соток в Карпатах, Верховина', 'Верховина, пр. Замагора, участок 35-соток с прекраснейшим видом на горы и лес, свет на участке, водный источник внизу участка, рельеф горный! Вокруг тишина и покой, которыми можно насладится и отдохнуть от повседневной суеты, войти сказочную атмосферу и побыть сам на сам с природой! Смена целевого назначения земли, делаем под заказчика!', 'Верховина, Ивано-Франковская область, Украина', 'B7Bmu4O8WC4', 31, 2),
(23, 'Предлагаю 3-дома по 200м² в Карпатах, Кривополье', 'Кривополье, Верховинского района, Ивано-Франковской области. Государственные акты для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений- 15 соток; 15 соток; 15 соток). На каждом участке есть дом 200 кв.м. (90% готовности). Возле центральной дороги. Рядом течет река. До районного центра - 10 км. До областного центра - 110км. В Буковель - 50км. На этой территории, от прекрасного вида первоначальной природы захватывает дух! Вокруг тишина и покой, которыми можно насладиться и отдохнуть от повседневной суеты, войти в сказочную атмосферу и побыть наедине с природой! Цена - 90.000 у.е. за один участок с домом.', 'с. Кривополье, Верховинский район, Ивано-Франковской области, Украина', 'D2ljCcb-ync', 29, 2),
(24, 'Продам пару зданий 200м2 и 50м2 под коммерцию на берегу реки в центре Верховины', 'Предлагаю пару домов на берегу реки в центре Верховины, возле пляжа! 1-й дом 50м2 и 10-соток земли, второе здание 200м2 и 15-соток земли, со всеми коммуникациями! Отличное место под коммерческие объекты! Верховинский район горист, такой красоты вы нигде больше не встретите, он окружен горами Поп Иван, Пушкар, Ледескул, Змиинська Велика, Великий Погар, Малый Погар, Магурка, Копилаш, Писаний Каминь, Синицы, Красник, Била Кобыла, Ребра, Жовнирська, Билинчукив Верх, Бребенескул, Вухатий Камень, Смотрич, Дземброня, Васкуль, Мунчел, Керничний, Шпыци, Велика Маришевська, Кострич, Гига, Костриця, Стиг, Кострич, Скупова,Тарниця, Баба Лудова, Велика Будийовська, Чивчин, Коман, Лостун, Пирье, Штивьора, Каменець, Крента Верхня, Крента Нижня, Грегит, Ротило, Чорний Грунь, Игрець, Роги. Ряд хребтов и вершин, создают необычную своеобразную экзотику. Рядом находится школа рафтинга, горнолыжный трамплин и 2 бугельных подъемника 450м и 750м, церковь Пресвятой Троицы и деревянная Троицкая церковь- 1881г. Активный отдых - сбор грибов и ягод летом, катание на лыжах зимой, походы в горы и катание на лошадях целый год.', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'VATjOdw_6Uk', 25, 2),
(33, 'Ділянки 500-сотих та 800-сотих на Буківецькому перевалі', 'Пропоную земельні ділянки 500-сотих та 800-сотих в с.Буківець, на Буківецькому перевалі, з дуже гарним та казковим краєвидом на гірські пейзажі, ділянка знаходиться біля дороги, яка проходить по туристичному маршруту на Писаний Камінь. Круглорічний під\'їзд до ділянки, чарівна вода, світло. Вдалий вибір місця, дозволяє реалізувати чималі переваги життя та бізнесу в Карпатах. І головне - життя в здоровій обстановці, на лоні природи, чиста вода, не забруднене повітря, на чарівній території, зробіть це для своєї сім\'ї. Навколо тиша і спокій, якими можна насолодитися і відпочити від повсякденної суєти, увійти в казкову атмосферу і побути сам на сам з природою!', 'с. Буковец, Верховинский район, Ивано-Франковской области, Украина', 'sMVCp_R7V0k', 34, 2),
(34, '100-сотих на Буківецькому перевалі з дуже казковим краєвидом на гірські пейзажі', 'Пропоную земельну ділянку 100-сотих на Буківецькому перевалі з дуже гарним та казковим краєвидом на гірські пейзажі. Круглорічний під\'їзд до ділянки, чарівна вода, світло. Вдалий вибір місця і будинку дозволяє реалізувати чималі переваги життя в Карпатах. І головне - життя в здоровій обстановці, на лоні природи, чиста вода, не забруднене повітря, на особистій території, з можливістю при бажанні самостійно вирощувати овочі та фрукти для своєї сім\'ї. Навколо тиша і спокій, якими можна насолодитися і відпочити від повсякденної суєти, увійти в казкову атмосферу і побути сам на сам з природою!', 'с. Буковец, Верховинский район, Ивано-Франковской области, Украина', 'COL_ag_ekHM', 33, 2),
(35, '20-соток земли, возле лечебно-оздоровительного комплекса «Верховина»', 'Гуцульская столица Верховина. Предлагаю 20-соток земли, которые находится возле лечебно-оздоровительного комплекса «Верховина», идеальное место для коммерции! Верховинский район горист, такой красоты вы нигде больше не встретите, он окружен горами Поп Иван, Пушкар, Ледескул, Змиинська Велика, Великий Погар, Малый Погар, Магурка, Копилаш, Писаний Каминь, Синицы, Красник, Била Кобыла, Ребра, Жовнирська, Билинчукив Верх, Бребенескул, Вухатий Камень, Смотрич, Дземброня, Васкуль, Мунчел, Керничний, Шпыци, Велика Маришевська, Кострич, Гига, Костриця, Стиг, Кострич, Скупова,Тарниця, Баба Лудова, Велика Будийовська, Чивчин, Коман, Лостун, Пирье, Штивьора, Каменець, Крента Верхня, Крента Нижня, Грегит, Ротило, Чорний Грунь, Игрець, Роги. Ряд хребтов и вершин, создают необычную своеобразную экзотику. Рядом находится школа рафтинга, горнолыжный трамплин и 2 бугельных подъемника 450м и 750м, церковь Пресвятой Троицы и деревянная Троицкая церковь- 1881г. Активный отдых - сбор грибов и ягод летом, катание на лыжах зимой, походы в горы и катание на лошадях целый год', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'aQFCkRsc4Kk', 34, 2),
(36, 'Роскошный участок земли 5-га в Карпатах под коттеджный Эко-городок!', 'Роскошный участок земли 5-га в Карпатах, с.Ильцы, под коттеджный Эко-городок! Поверхность села гористая, оно окружено горами Великий Погар (1322м), Малый Погар (1122м), Кострич (1585м), Магурка (1025м), Билинчукив Верх. От замечательного вида с этого участка, захватывает дыхание, глядя на красоты первозданной природы! Ряд хребтов и вершин, создают необычную своеобразную экзотику. Рядом находится школа рафтинга и 2 бугельных подъемника 450м и 750м! Среди достопримечательностей, церковь Пресвятой Троицы и деревянная Троицкая церковь (1881г). Ближайшие горнолыжные курорты: Верховина-4км, Ворохта-25км, Яблуница-32км, Косов-40км, Буковель-46км. Для любителей активного отдыха - сбор грибов и ягод летом, катание на лыжах зимой, походы в горы и катание на лошадях целый год. Это место притягивает духовников и монахов своей вселенской тишиной и отсутствием суеты. Ночи здесь дарят покой и умиротворение. Утро будит пением птиц. Когда вы распахнете свое окно на рассвете, вдохнете свежий воздух и энергию пробуждающейся природы, только тогда по-настоящему почувствуете себя живым.', 'с. Ильцы, Верховинский район, Ивано-Франковской области, Украина', 'DrhOCvjWedo', 33, 2),
(37, 'Продажа дома 70м2 на прекрасных 70-сотках в с.Ильцы, Карпаты', 'Ильцы, центр, дом-70м2, 70-соток (18-строительство + 52-ОСГ), 100м от дороги и церкви, навес, конюшня, подвал (пивниця), колодец, свет, вода в доме из источника, рядом горнолыжный курорт.', 'Ильцы, Верховинский район, Ивано-Франковской области, Украина', 'UTbjYEzg2VA', 25, 2),
(38, 'Продажа участка 8-соток под строительство со всеми коммуникациями в Верховине', 'Верховина, продажа участка 8-соток под строительство со всеми коммуникациями, возле центральной дороги, отличный подъезд к участку, 20-метров река Черный Черемош, 200-метров горнолыжный трамплин, элитные соседи! Вокруг тишина и покой, которыми можно насладится и отдохнуть от повседневной суеты, войти сказочную атмосферу и побыть сам на сам с природой! Верховина является одним из лидеров карпатского края, более 100 источников минеральных вод. Отдых в Верховине порадует туристов своей красотой естественных горных ландшафтов. Ряд хребтов и вершин, которые окружают поселок, создают необычную своеобразную экзотику. Снег лежит на них почти до середины июля, и прямо из окрестностей посёлка можно любоваться величественной панорамой гор. Горы Белая Кобыла(1473м), Синица(1186м), Мазурка(1025м), Пушкарь(812м), Бребенескул(2032м), Петрос(2020м), Гутин Томнатик(2016м), Ребра(2010м), Поп-Иван(2022м) с руинами метеорологической обсерватории на самой вершине, являются любимыми местами для посещения туристов. В одном из ледниковых каров на склонах горы расположено высокогорное озеро с ласковым названием Маричейка.', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'bm7gKU4gIPI', 33, 2),
(39, 'Продажа 2-х домов и 33-сотки земли в Верховине', 'Верховина, 1-й дом 120 м2, 2-й дом 60 м2, 35-соток земли, сарай, вода-поток, ставок, свет, 3-км до центра. Вокруг тишина и покой, которыми можно насладится и отдохнуть от повседневной суеты, войти сказочную атмосферу и побыть сам на сам с природой! Верховина является одним из лидеров карпатского края, более 100 источников минеральных вод. Отдых в Верховине порадует туристов своей красотой естественных горных ландшафтов. Ряд хребтов и вершин, которые окружают поселок, создают необычную своеобразную экзотику. Снег лежит на них почти до середины июля, и прямо из окрестностей посёлка можно любоваться величественной панорамой гор. Горы Белая Кобыла(1473м), Синица(1186м), Мазурка(1025м), Пушкарь(812м), Бребенескул(2032м), Петрос(2020м), Гутин Томнатик(2016м), Ребра(2010м), Поп-Иван(2022м) с руинами метеорологической обсерватории на самой вершине, являются любимыми местами для посещения туристов. В одном из ледниковых каров на склонах горы расположено высокогорное озеро с ласковым названием Маричейка. Украинские Карпаты владеют значительным курортно-рекреационным потенциалом. В последние десятилетия во всем мире активно развивается и пропагандируется экологический туризм. В Карпатском заповеднике, благодаря естественным особенностям, а также функциональному зонированию территории, представленные наилучшие условия именно для развития этого направления рекреации.', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'ijpRunhzb8A', 25, 2),
(40, 'Предлагаю божественный участок 50-соток в Карпатах, Дземброня', 'Предлагаю божественный участок 50-соток, 500м от центральной дороги в Дземброня, Верховинского района, Ивано-Франковской области. До Верховины- 10км. До обласного центра-130км. До Буковеля-70 км. Найизвестнейшая карпатская гора Поп Иван(2022м) с руинами метеорологической обсерватории на самой вершине, она входит до самого высокого и привлекательного для туристов горного хребта в Украине- Чорногора. В одном из ледниковых каров на склонах горы расположено высокогорное озеро с ласковым названием Маричейка. Самым коротким выходом на эту гору, есть дорога из Дземброни.\nЗдоровье нельзя купить, но при этом можно купить здоровые условия для жизни - чистый воздух, неповторимый горный ландшафт, ежедневное использование чистейшей воды. Мы предлагаем Вам участок, на котором будет Ваш дом-санаторий! Человек, который ценит здоровье - глядя в будущее, обязательно рассмотрит вариант жить в доме, что построен из экологически чистых материалов, находясь в экологически чистом регионе, который по сути является домом мини-санаторием. Жить ЗДОРОВО- не запретишь! ', 'Дземброня, Верховинский район, Ивано-Франковской области, Украина', 'iHfg9wloN7w', 33, 2),
(41, 'Прекрасных 25 соток на берегу реки Черемош в Карпатах, Ильцы', 'Ильцы, участок 25-соток (10-соток застройка, 10-соток ОСГ, 5-соток прибрежной полосы), граничит с рекой, в стороне пруд, но он зарос, можно почистить и делать форельное хозяйство! От главной дороги 50 метров! Рядом церковь, магазины, кафе. Свет и вода 1-метр от участка!', 'Ильцы, Верховинский район, Ивано-Франковской области, Украина', 'S5ySc2ZdJs4', 33, 2),
(42, 'Чудові 29-соток біля дороги Верховина – Буковель – Івано-Франківськ', 'Ільці, 29-соток біля дороги Верховина – Буковель – Івано-Франківськ, 2-фундаменти: 1) 9.5м х 11м; 2) 8м х 9м. Світло на ділянці, вода – колодязь. Вид на гірськолижний спуск та Черногірський Хребет. З розслаблюючого відпочинку, тут є практично все. В районі нараховується 455 річок загальною протяжністю понад 2000 км. Чорний Черемош - одна з небагатьох придатних для сплаву порожистих річок України. Зокрема тут є рафтинг, катання на конях, санях, та 45-радіальних одноденних туристичних маршрутів, 2 -водних, 5-велосипендиних т.д. Гори Біла Кобила (1473м), Синиця (1186м), Мазурка (1025м), Пушкар (812м), Бребенескул (2032м), Петрос (2020м), Гутин Томнатик (2016м), Ребра (2010м), Піп-Іван (2022м) з руїнами метеорологічної обсерваторії на самій вершині, є улюбленими місцями для відвідування туристів. В одному з льодовикових карів на схилах гори розташовано високогірне озеро з ласкавою назвою Марічейка. Ціна - 29000у.о./ торг!', 'Ильцы, Верховинский район, Ивано-Франковской области, Украина', 'XfQ3CBIJhLw', 34, 2),
(43, 'Продажа дома в живописном и божественном месте Карпат, пгт.Микуличин', 'Продажа дома в живописном и божественном месте Карпат, пгт.Микуличин, дом общая- 75м2, 3-комнаты, 22-сотки земли, стены из бруса, в доме есть свет, печка, централизованная вода, спутниковое телевидение, расположенном в живописном месте - между Яремче и Буковель. Чистый горный воздух, сосновые леса и река Прут. Расстояние до Яремче - 15км, до Буковеля - 20км. Заезд в плохом состоянии.', 'Микуличин, Ивано-Франковской области, Украина', 'b08cJ830zXc', 25, 2),
(44, 'Продажа дома 109м2 в божественном месте с младенческой природой с.Зелене, Карпаты', 'Продажа дома в божественном месте с нетронутой младенческой природой Карпат в с.Зелене, Верховинского района, общая площадь -108,5м2, 2-этажа, 4-комнаты, участок 5-соток, огражден и облагорожен, электричество три фазы, вода постоянно холодная и горячая (бойлер), индивидуальное отопление (котёл). Полностью укомплектован мебелью. На участке баня на дровах с мансардным этажом. Через дорогу горная река Чёрный Черемош, вокруг горы и лес.', 'Зелене, Верховинский район, Ивано-Франковской области, Украина', 'iHfg9wloN7w', 25, 2),
(45, 'Элитный коттедж на своей охраняемой территорией в Карпатах, Верхний Ясенов', 'Продажа элитного коттеджа на своей охраняемой территорией в Карпатах, Верховина, c.Верхний Ясенов, дом в горах 2-х этажный, вид на реку, общая- 172м2/102м2/16.3м2- кухня, 65,5-соток земли, 7-комнат, 3-сан.узла, сауна, бассейн, беседка, баня, 2-гаража, 2-камина, водопровод, телевизор, холодильник, кухонный уголок, стиральная машина, душевая кабина, ванна, газовая плита, духовка, телефонная разводка, встроенный шкаф-гардероб, меблированная кухня, диван / мягкий уголок, счетчик на электричество, вода- скважина, подогрев воды- бойлер, спутниковое TV, дом для охраны, хозяйственные постройки, выход к водоему. Все для волшебного отдыха и проживания! Чистейший воздух!', 'Верхний Ясенов, Верховинский район, Ивано-Франковской области, Украина', 'QuJvAU8iUt8', 29, 2),
(46, 'Продажа очаровательного дома 142м2 в Старый Лисец, Карпаты', 'Продажа великолепного и очаровательного дома в Карпатах, Тысменицкий район, с.Старый Лисец. Дом- 142м2 + гараж 24м2, 2015 года-постройки, 5-комнат, 2-этажа, кухня-12м2, участок-10 соток. В доме полноценные этажи, а не мансарда, все стены- кругляк диаметр 20см. Возможно продажа одного дома!', 'Старый Лисец, Тысменицкий район, Ивано-Франковской области, Украина', 'QuJvAU8iUt8', 25, 2),
(47, 'Продажа дома 63м2 на 30 сотках в очаровательном месте с.Криворовня, Карпаты', 'Продажа дома в очаровательном месте Карпат, с.Криворовня. Дом - 63м2, 3-комнаты, 150м от центральной дороги, площадь земельного участка 22-сотки плюс 8-соток отдельно 500м от дома, баня с парилкой, конюшня для скота (новая), подвал, колодец, навес для сена, металлическая ограда с ламинированной сеткой, хозяйственное помещение из двух частей, помещения для хранения дров.', 'Криворовня, Верховинский район, Ивано-Франковской области, Украина', '5BzpZvbpWjA', 25, 2),
(48, 'Продажа дома 120м2 на 27-сотках в чистейшем месте Карпат, c.Хороцево', 'Продажа дома в чистейшем месте Карпат, c.Хороцево. Общая площадь дома 120м2/100м2/15м2-кухня, участок - 27 соток, электричество в доме, вода- колодец, отопление печное. Дом в отличном состоянии, прекрасное место для проживания семьи. Горный воздух, родниковая вода, прекрасное место для выращивания собственных овощей и фруктов, фруктовый сад. Место для отдыха и проживания!', 'Хороцево, Верховинский район, Ивано-Франковской области, Украина', 'QuJvAU8iUt8', 25, 2),
(49, 'Продажа дома 160м2 в сказочной месте Верховины, с.Головы', 'Верховина, c.Головы. Общая площадь дома: 160м2: 1 этаж- 99м2, 2- этаж 61м2. Материал конструкций дома: деревянные протесы. Помещения: гостиная, кухня, 4-спальни, 3 гардеробных, санузел с душевой кабиной, электрическая плита, духовка, бойлер, зимний сад, электричество в доме, вода – скважина, отопление- электрическое. Коммуникации: горячее (бойлер) и холодное водоснабжение, канализация. До Буковеля: 58км. До пгт. Верховина 15км. Площадь земельного участка: 54-сотки.', 'Головы, Верховинский район, Ивано-Франковской области, Украина', 'O8imt4wG9hQ', 29, 2),
(50, 'Продажа коттеджа 135 м2 в живописном месте Быстрец, у подножья горы Поп Иван', 'Продажа коттеджа в живописном месте Карпат, Быстрец, Красник, у подножья горы Поп Иван, рядом обсерватория.  Общая-135 м2/ жилая-91 м2/12 м2-кухня, 5-комнат. Участок-12 соток. Камин, кухонный уголок, душевая кабина, газовая плита, счетчик на электричество, высота потолка: 2.77 м, крыша: металлочерепица, электричество: в доме, вода: автоматическая с колодца, отопление: печное, подогрев воды: бойлер, канализация: сливная яма, TV: спутниковое, 2- санузела, лоджия- 1, выход к водоему: 1-я линия (с непосредственным выходом), персональный водоем: ручей.', 'Быстрец, Верховинский район, Ивано-Франковской области, Украина', 'iHfg9wloN7w', 29, 2),
(51, 'Продажа дома 213м2 в божественном месте Карпат, Верховина', 'Продажа дома в божественном месте Карпат, Верховина. Новый дом 2014-года. 213м2/108м2/27м2-кухня с земельным участком в 20 соток в живописном месте, недалеко лес и речка. Воздух чистый, свежий, звёздное небо, вокруг тихо. Дом подготовлен к внутренним работам. Мансандровый этаж утеплён. Проведён интернет, свет. На участке имеется водоём с рыбами. Дом можно использовать под мини-отель.', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'ZxG2eL1ygXo', 29, 2),
(52, 'Продажа дома 85м2 в неописуемом месте Карпат, Гринява', 'Продажа дома в сказочном и божественном месте Карпат, c.Гринява, Верховинского района, дом из бруса, общая-85м2/65м2/10м2-кухня, 2-этажа, 4-комнаты, 100-соток земли, все приватизировано, свет, интернет Интертелекомовський и спутниковое телевидении, вода родниковая, сад у дома, грибы недалеко от дома, ягоды малина и прочее! 2-км надо идти пешком, туристическое место! Возможен торг!', 'Гринява, Верховинский район, Ивано-Франковской области, Украина', 'QuJvAU8iUt8', 25, 2),
(53, 'Бесценный по красоте участкок 80-соток в Карпатах, Замагора', 'Бесценные по красоте участки в Карпатах, Замагора, 80 соток, находится не далеко от горнолыжного трамплина и национального парка! На участке есть вода, электричество, строения. От прекрасного вида первозданной природы захватывает дыхание: грациозные деревья с вечнозелеными лохматыми ветвями дремлют в утренней дымке, солнце радужно освещает застывшие в глубоком раздумье горы. Вокруг тишина и покой, которыми можно насладится и отдохнуть от повседневной суеты, войти сказочную атмосферу и побыть сам на сам с природой! Есть еще рядом участок в 800 соток. Это место притягивает духовников и монахов своей вселенской тишиной и отсутствием суеты. Ночи здесь дарят покой и умиротворение. Утро будит пением птиц. Когда вы распахнете свое окно на рассвете, вдохнете свежий воздух и энергию пробуждающейся природы, только тогда по-настоящему почувствуете себя живым.', 'Замагора, Верховинский район, Ивано-Франковской области, Украина', 'LqyHMrPLBp0', 33, 2),
(54, 'Продажа божественного участка 50 соток возле подъемника в с. Красник, Карпаты', 'с.Красник, Верховинського району, Івано-Франківської області. Державні акти: для ведення особистого селянського господарства на 50 -соток, возле подъемника. Поможем с переводом земли под строительство! Рядом есть еще 40 и 90 -соток. Під\'їзд- 1км від центральної дороги. До районного центру- 8км. До обласного центру- 110км. До Буковелю- 50км.', 'Красник, Верховинский район, Ивано-Франковской области, Украина', 'OizPJ4wAmfk', 32, 2),
(55, 'Продажа божественного участка 40 соток в с. Красник, Карпаты', 'с.Красник, Верховинського району, Івано-Франківської області. Державні акти: для ведення особистого селянського господарства на 40-соток. Поможем с переводом земли под строительство! Рядом есть еще 50-соток и 90-соток ОСГ. Під\'їзд- 1км від центральної дороги. До районного центру- 8км. До обласного центру- 110км. До Буковелю- 50км.', 'Красник, Верховинский район, Ивано-Франковской области, Украина', 'OizPJ4wAmfk', 32, 2),
(56, 'Продажа божественного участка 90 соток в с. Красник, Карпаты', 'с.Красник, Верховинського району, Івано-Франківської області. Державні акти: для ведення особистого селянського господарства на 90-соток. Поможем с переводом земли под строительство! Рядом есть еще 50-соток и 40-соток ОСГ. Під\'їзд- 1км від центральної дороги. До районного центру- 8км. До обласного центру- 110км. До Буковелю- 50км.', 'Красник, Верховинский район, Ивано-Франковской области, Украина', 'OizPJ4wAmfk', 32, 2),
(57, 'Продажа сказочного участка 23 сотки под строительство в с. Красник, Карпаты', 'с.Красник, Верховинского района Ивано-Франковской области. Государственный акт: для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений 23-соток.\nПодъезд- 1км от центральной дороги. До районного центра- 8км. До областного центра- 110км. До Буковелю- 50км.\nТакже есть для ведения личного крестьянского хозяйства 40-соток; 50-соток; 90-соток). Поможем с переводом ОСГ земли под строительство!', 'Красник, Верховинский район, Ивано-Франковской области, Украина', 'OizPJ4wAmfk', 33, 2),
(58, 'Продажа прекрасного участка 12 соток в с.Ильцы, Гуцульщина', 'с.Ильцы, Верховинского района, Ивано-Франковской области. Государственные акты: для ведения личного крестьянского хозяйства (0,12 га; 0,12 га; 0,9 га; 0,20 га). Поможем с переводом земли под строительство! Подъезд- 1км от центральной дороги. Свет есть на участках. Рядом протекает река. До районного центра- 7км. До областного центра- 110км. До Буковеля- 50км.', 'Ильцы, Верховинский район, Ивано-Франковской области, Украина', 'uN7ZDToedA0', 32, 2),
(59, 'Продажа участка 17 соток под коммерческое строительство в с.Ильцы, Карпаты', 'с.Ильцы, Верховинского района. Государственный акт: для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений 17-соток. Подъезд- 1км от центральной дороги. Свет есть на участках. Рядом протекает река. До районного центра- 7км. До областного центра- 110км. До Буковеля- 50км', 'Ильцы, Верховинский район, Ивано-Франковской области, Украина', 'uN7ZDToedA0', 34, 2),
(60, 'Продажа участка 20 соток в с.Ильцы, Карпаты', 'с.Ильцы, Верховинского района Ивано-Франковской области. Государственный акт: для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений 20-соток. Подъезд- 200м от центральной дороги. Свет, вода на участке. Рядом протекает река. До районного центра- 7км. До областного центра- 110км. До Буковеля- 50км.', 'Ильцы, Верховинский район, Ивано-Франковской области, Украина', 'uN7ZDToedA0', 33, 2),
(65, 'Продажа участка 30 соток в с.Ильцы, Прикарпаття', 'с.Ильцы, Верховинского района, Ивано-Франковской области. Общая площадь участка 30-соток. Государственный акт для ведения личного крестьянского хозяйства. Поможем с переводом земли под строительство! Подъезд - 200м от центральной дороги. Рядом протекает ручей. До районного центра - 10км. До областного центра - 110км. До Буковеля - 50км.', 'Ильцы, Верховинский район, Ивано-Франковской области, Украина', 'QuJvAU8iUt8', 33, 2),
(64, 'Продажа участка 370 соток в с.Ильцы, Прикарпаття', 'с.Ильцы, Верховинского района, Ивано-Франковской области. Общая площадь участка 3,7га (370соток). Государственные акты для ведения личного крестьянского хозяйства. Поможем с переводом земли под строительство! Возможно разделение на участки. Подъезд - 500м от центральной дороги. Свет, вода на участке. Рядом протекает ручей. До районного центра - 10км. До областного центра - 110км. До Буковеля - 50км.', 'Ильцы, Верховинский район, Ивано-Франковской области, Украина', 'DrhOCvjWedo', 33, 2),
(66, 'Продам участок 75 соток в с.Дземброня под строительство объектов здоровья и отдыха', 'с.Дземброня, гора Смотрич, Верховинского района, Ивано-Франковской области. Государственные акты: для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений (0,25 га), для ведения личного крестьянского хозяйства (0,50 га). Подъезд - 300м от центральной дороги. Свет, вода на участке. Рядом протекает ручей. с.Дземброня (760м над уровнем моря) издавна славится своими уникальными видами на Черногору со стороны хребта Косарище, чистотой воздуха, расположенных недалеко от Черногорского хребта. До районного центра - 7 км. До областного центра - 120 км. До Буковеля - 60 км.', 'Дземброня, Верховинский район, Ивано-Франковской области, Украина', 'iHfg9wloN7w', 34, 2),
(67, 'Продам участок 50 соток в с.Дземброня, на г.Смотрич', 'с.Дземброня, Верховинского района, Ивано-Франковской области. Дземброня (760м над уровнем моря) издавна славится своими уникальными видами на Черногору со стороны хребта Косарище, чистотой воздуха, расположенных недалеко от Черногорского хребта. Общая площадь участка 50 соток. Государственный акт для ведения личного крестьянского хозяйства. Подъезд - 2км от центральной дороги. До районного центра - 20км. До областного центра - 130км. До Буковеля - 70км.', 'Дземброня, Верховинский район, Ивано-Франковской области, Украина', 'iHfg9wloN7w', 32, 2),
(68, 'Продам участок 25 соток под строительство в с.Дземброня, на г.Смотрич', 'с.Дземброня, на г.Смотрич, Верховинского района, Ивано-Франковской области. Дземброня (760м над уровнем моря) издавна славится своими уникальными видами на Черногору со стороны хребта Косарище, чистотой воздуха, расположенных недалеко от Черногорского хребта. Общая площадь участка 25 соток. Государственный акт для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений. Подъезд- 2км от центральной дороги. До районного центра- 20км. До областного центра- 130км. До Буковеля- 70км.', 'Дземброня, Верховинский район, Ивано-Франковской области, Украина', 'iHfg9wloN7w', 33, 2),
(69, 'Продам участок 20 соток под строительство в с.Дземброня', 'Дземброня, Верховинского района, Ивано-Франковской области. Государственный акт для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений 20 соток. Подъезд - 300м от центральной дороги. Свет, вода на участке. Рядом протекает ручей. До районного центра - 7 км. До областного центра - 120 км. До Буковеля - 60 км. Дземброня (760м над уровнем моря) издавна славится своими уникальными видами на Черногору со стороны хребта Косарище, чистотой воздуха, расположенных недалеко от Черногорского хребта.', 'Дземброня, Верховинский район, Ивано-Франковской области, Украина', 'iHfg9wloN7w', 33, 2),
(70, 'Продам участок 75 соток под коммерцию в с.Дземброня (Берестечко)', 'с.Берестечко (Дземброня), Верховинского района, Ивано-Франковской области.\nГосударственные акты: для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений (0,25 га), для ведения личного крестьянского хозяйства (0,50 га). Подъезд - 300м от центральной дороги. Свет, вода на участке. Рядом протекает ручей. До районного центра - 7 км. До областного центра - 120 км. До Буковеля - 60 км. с.Дземброня (760м над уровнем моря) издавна славится своими уникальными видами на Черногору со стороны хребта Косарище, чистотой воздуха, расположенных недалеко от Черногорского хребта.', 'Дземброня, Верховинский район, Ивано-Франковской области, Украина', 'iHfg9wloN7w', 33, 2),
(71, 'Продам участок 7 соток под строительство и коммерцию в с.Дземброня', 'с.Дземброня, Верховинского района, Ивано-Франковской области. Дземброня (760м над уровнем моря), издавна славится своими уникальными видами на Черногору со стороны хребта Косарище, чистотой воздуха, расположенных недалеко от Черногорского хребта. Общая площадь участка 7 соток. Государственный акт для ведения личного крестьянского хозяйства. Поможем с переводом земли под строительство! Подъезд - 50м от дороги. Свет, вода на участке. Рядом течет река. До районного центра- 18 км. В областной центр- 125км. До Буковеля- 65км.', 'Дземброня, Верховинский район, Ивано-Франковской области, Украина', 'iHfg9wloN7w', 33, 2),
(72, 'Продам участок 25 соток под коммерцию в с.Дземброня (Берестечко)', 'с.Берестечко (Дземброня), Верховинского района, Ивано-Франковской области.\nГосударственные акты: для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений (0,25 га). Подъезд - 300м от центральной дороги. Свет, вода на участке. Рядом протекает ручей. До районного центра - 7 км. До областного центра - 120 км. До Буковеля - 60 км. с.Дземброня (760м над уровнем моря) издавна славится своими уникальными видами на Черногору со стороны хребта Косарище, чистотой воздуха, расположенных недалеко от Черногорского хребта.', 'Дземброня, Верховинский район, Ивано-Франковской области, Украина', 'iHfg9wloN7w', 33, 2),
(73, 'Самый красивый участок 17 соток у горнолыжного трамплина в Верховине,Карпаты', 'Самый красивый участок в Карпатах, почти даром, у горнолыжного трамплина, пгт.Верховина, 17-соток, возможно разделить (10-соток и 7-соток), свет, вода, 300 метров до горнолыжного трамплина, у реки, у гор, 3-км центр. Верховина является лидером карпатского края, более 100 источников минеральных вод. Ряд хребтов и вершин, окружающих, создают необычную своеобразную экзотику. Снег лежит на них почти до середины июля, и непосредственно из окрестностей поселка можно любоваться величественной панорамой гор. Вокруг тишина и покой, которыми можно насладиться и отдохнуть от повседневной суеты, войти сказочную атмосферу и побыть наедине с природой!', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', '1jt2TBNm-rk', 33, 2),
(74, 'Продам участок 50 соток под строительство в Верховине', 'пгт. Верховина, Верховинского района, Ивано-Франковской области. Общая площадь участка 50 соток. Государственный акт для ведения личного крестьянского хозяйства. Поможем с переводом целевого назначения участка под строительство. Подъезд - 1 км от центральной дороги. Свет, вода рядом с участком. До областного центра - 120 км. До Буковеля - 60 км.', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'QuJvAU8iUt8', 32, 2),
(75, 'Продам участок 9 соток под строительство и коммерцию в Верховине', 'пгт. Верховина, Верховинского района Ивано-Франковской области. Государственные акты: для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений- 8,86 соток и 13,72 соток, для ведения личного крестьянского хозяйства- 11,46 соток. Подъезд- 300м от центральной дороги. Свет и вода на участке. До областного центра-120км. До Буковеля - 60 км.', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'QuJvAU8iUt8', 33, 2),
(76, 'Продам участок 15 соток под строительство и коммерцию в Верховине', 'Продаются участки земли в Верховине с великолепным видом на горы: 9-соток, 11.5-соток, 13.7-соток, 15-соток, 50-соток. Подъезд – 300м от центральной дороги. Свет и вода на участке. Верховина- гуцульская столица, является лидером карпатского края, более 100 источников минеральных вод. В этой сказке любуешься величественной панорамой гор. Ряд хребтов и вершин, окружающих это чарующее место, создают необычную своеобразную экзотику. Вокруг тишина и покой, которыми можно насладиться и отдохнуть от повседневной суеты, войти сказочную атмосферу и побыть наедине с природой!', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'QuJvAU8iUt8', 33, 2),
(77, 'Продам участок 40 соток под коммерцию с прекрасным видом на Верховину', 'Гуцульская столица Карпат - Верховина, Верховинского района, Ивано-Франковской области. Меняем целевое назначение земли под заказчика (строительство жилья или коммерции), переведем до сделки! Государственные акты: для ведения личного крестьянского хозяйства (0,25 га; 0,40 га; 0,40 га, 0,50 га; 0,65 га; 0,90 га). Подъезд - 1км от центральной дороги. Свет есть на участках. До областного центра - 120 км. В Буковель - 60км.', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'r27yEZdKgX8', 31, 2),
(78, 'Продам участок 25 соток под коммерцию с прекрасным видом на Верховину', 'Гуцульская столица Карпат - Верховина, Верховинского района, Ивано-Франковской области. Меняем целевое назначение земли под заказчика (строительство жилья или коммерции), переведем до сделки! Государственные акты: для ведения личного крестьянского хозяйства (0,25 га; 0,40 га; 0,40 га, 0,50 га; 0,65 га; 0,90 га). Подъезд - 1км от центральной дороги. Свет есть на участках. До областного центра - 120 км. В Буковель - 60км.', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'r27yEZdKgX8', 33, 2),
(79, 'Продам участок 90 соток под строительство с прекрасным видом на Верховину', 'Гуцульская столица Карпат - Верховина, Верховинского района, Ивано-Франковской области. Меняем целевое назначение земли под заказчика (строительство жилья или коммерции), переведем до сделки! Государственные акты: для ведения личного крестьянского хозяйства (0,90 га; 0,25 га; 0,40 га; 0,50 га; 0,65 га). Подъезд - 1км от центральной дороги. Свет есть на участках. До областного центра - 120 км. В Буковель - 60км.', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'r27yEZdKgX8', 34, 2),
(80, 'Продам идеальных под коммерцию 18 соток земли в Верховине, Карпаты', 'пгт.Верховина, Верховинского района, Ивано-Франковской области. Общая площадь участка 18 соток. Государственные акты: для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений (0,10 га), для ведения личного крестьянского хозяйства (0,08 га). Возле центральной дороги. Есть свет и вода. Рядом протекает река. До областного центра - 120 км. До Буковеля - 60 км.', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'QuJvAU8iUt8', 34, 2),
(81, 'Продам прекрасный участок 50 соток в Верховине, Карпаты', 'пгт. Верховина, Верховинского района, Ивано-Франковской области. Общая площадь участка 50 соток. Государственный акт для ведения личного крестьянского хозяйства. Поможем в смене целевого назначения участка под строительство, коммерцию или сделаем перевод до сделки! Подъезд - 500м от центральной дороги. Свет, вода на участке. Рядом протекает ручей. До областного центра - 120 км. До Буковеля - 60 км.', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'QuJvAU8iUt8', 33, 2),
(82, 'Продам землю 100 соток с прекрасным видом на горы в Карпатах, Буковец', 'Буковец, прис.Черетив, Верховинского района, Ивано-Франковской области. Общая площадь участка 100 соток. Государственный акт для строительства и обслуживания жилого дома, хозяйственных зданий и сооружений. Подъезд - 5км от центральной дороги. Свет, вода на участке (ручей). До районного центра - 15км. До областного центра - 130км. До Буковеля - 70км.', 'Буковец, Верховинский район, Ивано-Франковской области, Украина', 'COL_ag_ekHM', 33, 2),
(83, 'Предлагаю Элитный Гостиничный Комплекс в сказочном месте Косова, Карпаты', 'Срочная продажа! Звоните сегодня, завтра этого предложения может не быть!\n Усадьба 660м2, расположилась на 15 сотках прекрасной земли в центре г. Косов, в живописной и неповторимой местности, под лесом, вдалеке от шумихи, движения и суматохи, одна из лучших частных усадеб Косовщины, возведенная в традиционном гуцульскому народном стиле, украшенные исключительно из дерева и речного камню, с авторскими картинами на стенах, выполненными уникальной техникой из коры деревьев, функционирует сауна с контрастным бассейном. Здесь, Вы сможете наслаждаться величественными пейзажами, походами в горы, водопадами, гуцульской экзотикой. Близ усадьбы находится канатно-бугельная выдержка с горнолыжными трассами! Вы найдете множество развлечений, которые подарят незабываемые воспоминания! Катание верхом или выезд в горы на конях карпатской породы, сплав по реке Черемош (Черный Черемош) на рафтах или байдарках с высококвалифицированными инструкторами, пейнтбол, автомобильные, вело маршруты по гуцульских Карпатам, а также сбор грибов, афинив, земляник, малины, ежевики в уникальных горных лесах вокруг усадьбы. Косовщина, - неповторимо живописный край высоких гор, стремительных потоков и чистого воздуха. Своеобразие края, красота его естественных ландшафтов, богатый животный и растительный мир Карпат, уникальная казна естественных экосистем, где сохранились редкие реликтовые виды флоры, фауны, и, как нигде в Украине, народные обычаи, традиционная бытовая культура, влекут к себе многочисленных туристов.', 'Косов, Косовский район, Ивано-Франковской области, Украина', 'sI5_HeJOQm8', 11, 2),
(84, 'Сказочный участок под санаторий в Карпатах, Верховина', 'Гуцульская столица - Верховина, Ивано-Франковской обл., участок- 2400 соток (125, 300, 530, 545 соток); находится 2 км от горнолыжного трамплина и национального парка в урочище Синицы! На участке есть минеральные источники воды, родник, горная речка, свет, строения. Отличный вариант под санаторий, гостиницу, лечебную здравницу! Гора Синицы (1186м.) - Одна из вершин Покутсько-Буковинских Карпат, расположенная в Верховинском районе Ивано-Франковской области. Гуцулы называют эту гору Довбушанка, ведь считают, что известный старший повстанцев когда-то жил там и спрятал в «Довбушевих кладовых» золотые сокровища. Украшением данного горного массива является так называемый каменный каньон - геологический памятник природы местного значения. Длина этого ущелья более 70м, ширина внизу - около 4м, а глубина достигает 20м. Там был снят один из эпизодов украинского художественного фильма «Олекса Довбуш» 1969 - переход повстанцев деревянной кладкой через глубокую пропасть между двумя скалами. От прекрасного вида первозданной природы захватывает дыхание: грациозные деревья с вечнозелеными лохматыми ветвями дремлют в утренней дымке, солнце радужно освещает застывшую в глубоком раздумье гору Говерлу. Если хотите ощутить приятный терпкий вкус красной бусинки-земляники или окрасить язык в синий цвет с помощью коварной черники, то немедля ступайте на лесную тропу. Здесь также будет, где разгуляться заядлому грибнику. Есть река, которую при желании можно превратить в пруд с кристально чистой водой, где потом с восторгом созерцать как собственное отражение, так и горную золотую рыбку – форель, которая непременно исполнит Ваше желание. Инвестиции в Карпаты – это инвестиции в своё здоровье, в здоровое будущее своих детей, возможность дышать свежим воздухом и пить чистую живую воду! Приобретая дома и земельные участки в Карпатах, Вы получаете взамен кусочек первозданной природы! Если Вы привыкли действовать,а не рассуждать–позвоните мне уже сегодня! Цена: от 300у.е. до 2000у.е./сотка, зависит от размера и месторасположения участка в этом месте!', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'ivkZr3RXa8Q', 34, 2);
INSERT INTO `offers` (`id`, `title`, `description`, `location`, `video`, `category_id`, `owner_id`) VALUES
(85, 'Лучшее место в Карпатах 125 - 2400 соток под строительство санатория в Верховина', 'Лучшее место в Карпатах, Верховина, участок 24 га (2400 соток), можно рассмотреть продажу частями (125, 275, 550, 650, 800 соток), находится 1,2км от горнолыжного трамплина и национального парка! На участке есть свои минеральные источники воды, родники, горная речка с водопадами, свет, строения. Местность прекрасная как для отдыха, так и для постоянного проживания для тех, кто решил сохранить здоровье, попить животворящую, природную воду, подышать воздухом, которое придает силы. Чтобы в этом убедиться, нужно только увидеть! Инвестиции в Карпаты – это инвестиции в своё здоровье, в здоровое будущее своих детей, возможность дышать свежим воздухом и пить чистую живую воду! Земля находится в регионе, включенным в предполагаемую заявку Украины на проведение зимней Олимпиады 2022 года.\nПреимущества жизни в Карпатах:\n1)Удачный выбор места позволяет реализовать немалые преимущества жизни в Карпатах.\n2)Владелец получает не только большую часть владений наилучшего места в Карпатах, но и шанс иметь великолепный огромный участок самого красивого места на Украине!\n3)Возможность пользоваться хотя бы минимальной обслуживающей инфраструктурой без дополнительной платы (минеральная вода, родники, река, дешевое электричество).\n4)И главное - жизнь в здоровой обстановке, на лоне природы, пить чистую воду, дышать чистейшим Карпатским воздухом, на личной территории, с возможностью при желании самостоятельно выращивать овощи и фрукты для своей семьи. Цена: от 300у.е. до 2000у.е./сотка, зависит от размера и месторасположения участка!', 'Верховина, Верховинский район, Ивано-Франковской области, Украина', 'ivkZr3RXa8Q', 34, 2),
(86, 'Продажа участка 75 соток вдоль дороги под коммерцию в Ильцы, Карпаты', 'Продажа участка под коммерцию в Ильцы, Верховина. 75-соток (25-соток под строительство и 50-соток ОСГ), вдоль трассы Верховина – Буковель – Ивано-Франковск, свет и вода присутствуют, рядом река Черный Черемош, горнолыжный курорт «Ильцы», напротив строиться паркинг для туристов. Вокруг великолепный вид на горы. Верховинський район, является одним из лидеров карпатского края, более 100 источников минеральных вод. Отдых здесь порадует туристов своей красотой естественных горных ландшафтов. Ряд хребтов и вершин, которые окружают, создают необычную своеобразную экзотику. Снег лежит на них почти до середины июля, и прямо из окрестностей посёлка можно любоваться величественной панорамой гор.', 'Ильцы, Верховинский район, Ивано-Франковской области, Украина', 'DQk4ef87__k', 34, 2),
(87, 'Волшебный участок 65 соток под строительство, у дороги в Карпатах, Криворовня', 'Криворовня- старинное карпатское село (упоминание датируется 1719г), прозванное \"украинскими Афинами\" как место вдохновения творческой интеллигенции. Это горнолыжный и эко-курорт, расположенный в лесистой местности на высоте 564-метра над уровнем моря, в живописной долине у подножия горы Варитин и хребта Игрец, в 3км к востоку от Верховина у излучины р.Чёрный Черемош. Природный потенциал Криворовни настолько оптимально сбалансирован, что даже один только воздух, способен исцелять от многих заболеваний, связанных с дыхательными путями, легкими, сердечно-сосудистой и нервной системой. В лесах знаменитые эдельвейсы, изобилие грибов и ягод, много дичи, лекарственные растения, некоторые очень редкие, равноценные дальневосточному женьшеню. Известно село своим высококачественным медом, за которым приезжают не только с Украины, но и из европейских государств. Целебные качества местного меда способны помочь в излечении некоторых тяжелых заболеваний. Еще здесь прекрасная национальная кухня и домашние виноградные вина. Есть несколько горнолыжных трасс, два бугельных подъемника. В реке водится сом, форель, щука, много частиковой рыбы. Рыбалка здесь отличная круглый год. В 1719г. заложена деревянная церковь Рождества Богородицы. В разное время здесь также бывали И. Франко, Л.Украинка, О.Кобылянская, М.Грушевский, В.Стефанык, К.Станиславский, М.Драгоманов, В.Немирович-Данченко, М.Стельмах, А.Малышко, Д.Павлычко и др. В настоящее время Криворовня превращается в село-музей. Действуют 14 этнографических и историко-биографических музеев: музей \"Гуцульская гражда\", музей гуцульского быта, дом-музей М. Грушевского. В последние воскресенье июня проходит народный праздник \"Проводы на полонину\". Самый известный маршрут на Довбушевые кладовые на г.Синицы (1186м), здесь по преданию старожилов, скрывались карпатские мстители- партизаны под руководством главаря Олексы Довбуша, где говорят он спрятал свои сокровища!\nЗнаменит курорт своим уникальным микроклиматом, экологически чистое место, великолепная природа, леса и горы. Климат умеренно-континентальный, очень мягкий. Благодаря защите горных хребтов здесь очень редко происходят какие-либо природные экстремальные ситуации типа засухи, сильных морозов или штормовых ветров. Солнечных дней в году около 62%. Лето теплое, плодородное, очень зеленое. Средняя температура июля днем 22-28 градусов, ночью - 18-20 градусов тепла. Зима снежная, на склонах снег держится до конца марта, что очень радует любителей горнолыжного туризма, лыжников и сноубордистов. Средняя температура 4-8 градусов мороза. Весна очень красивая, все три месяца здесь цветут луга и сады, наполняя воздух волшебными ароматами. Осень роскошная, одевающая окрестности в золотые наряды, красота карпатской осени не может сравниться ни с чем, как-будто попадаешь в волшебную сказку.', 'Криворовня, Верховинский р-н, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 34, 2),
(88, 'Загадочная и волшебная по своей красоте земля 280 соток на Буковецкой перевале', 'Площадь - 2,8 га (280 соток,государственные акты), 1000м над уровнем моря. Участок находится на территории Национального природного парка \"Гуцульщина\", неподалеку от знаменитого Писаного камня - конечного пункта многих горных туристических восхождений. На участке есть жилой дом 93м2, вода находится на участке 2 источника Н2О, линия электросетей 220V заведено в дом, счетчик новый. Три фазы 380V находятся на линии электросети, рядом с участком. Мобильная связь (UMC, UA-KYIVSTAR - полное покрытие). Сделана грунтовая подъездная дорога, по украинским меркам считается хорошей дорогой! Легковая машина, доезжает без проблем. К центральной дороги - 1,8км, до Верховины (р-н центр) - 16км, до Косов (р-н центр, горнолыжная трасса) - 17км, до Буковеля - 60 км. В свое время это место посетили О.Довбуш, И.Франко, М.Коцюбинский, О.Кобылянская, Г.Хоткевич и многие другие известные люди.', 'Буковец, Верховинский район, Ивано-Франковской области, Украина', 'PKHPIiDKAZc', 34, 2),
(90, 'Продается земельный участок 3500 соток для объектов отдыха и здоровья в Карпатах, с.Воловая', 'Предлагаю 35-га (3500соток) чудесной земли в с.Воловая, Кривопольский р-н. На этой территории, от прекрасного вида первозданной природы захватывает дыхание: грациозные дерева с вечнозелеными пушистыми ветвями дремлют в утренней дымке, солнце радужно освещает застывшие в глубокой задумчивости горы. Вокруг тишина и покой, которыми можно насладиться и отдохнуть от повседневной суеты, войти в сказочную атмосферу и побыть наедине с природой! Природный потенциал настолько оптимально сбалансирован, что даже один только воздух, способен исцелять от многих заболеваний, связанных с дыхательными путями, сердечно-сосудистой и нервной системой. В лесах знаменитые эдельвейсы, изобилие грибов и ягод, много дичи, лекарственные растения, некоторые очень редкие, равноценные дальневосточному женьшеню. Экологически чистое место, великолепная природа, леса и горы. Цена-договорная!', 'Воловая, Верховинский район, Ивано-Франковская область, Украина', 'TbwjqK78ac4', 31, 2),
(91, 'Продажа чудесного нового дома в Верховине, на берегу р.Черемош, Карпаты', 'На видео виден этот прекрасный коттедж 160м2 на берегу чудесной р.Черемош, возле горнолыжного трамплина, вокруг волшебные горы и девственный лес. Благодаря доступной цене и уникальному шансу, Вы получите частицу райского места в самом сердце Карпат, позволит реализовать фантастические мечты современного качества жизни в экологическом месте, на лоне природы, с доступом к чистой живой воде, целебному карпатскому воздуху, с возможностью выращивать на собственном участке овощи и фрукты! Дополнительные преимущества этого района – уникальный природный потенциал: минеральная вода, родники, река, дешевое электричество.Это удивительное и фантастическое место в Верховине, находится в самом центре Карпат и считается столицей Гуцульщины. Преимущества: 1) Вы можете реализовать фантастические мечты в экологичном месте, на лоне природы и получить частицу райского места планеты в самом сердце Карпат! 2) Уникальный природный потенциал: минеральная вода, родники, река, дешевое электричество. 3) Участок находится на уровне лучших зарубежных курортов! Известны Семь чудес Верховинщины: обсерватория на горе Поп Иван, геологическая памятка природы Писаный Камень, высокогорное озеро Маричейка, высокие скалы Шпицы, церковь Рождества Богородицы (с.Криворовня), Кладовые Довбуша на г.Синицы, скалы в парке Венгерское. Это место притягивает духовников и монахов своей вселенской тишиной и отсутствием суеты. Ночи здесь дарят покой и умиротворение. Утро будит пением птиц. Когда вы распахнете свое окно на рассвете, вдохнете свежий воздух и энергию пробуждающейся природы, только тогда по-настоящему почувствуете себя живым.', 'Верховина, Ивано-Франковская область, Украина', 'OYIMiLxnzYw', 25, 2),
(92, 'Дом и чудесный участок 140 соток в Гуцульской столице, с видом на горные хребты!', 'Верховина, Присілок Бречник. Чудесный участок 140 соток в Гуцульской столице, с видом на горные хребты! До центра - 1км. Отличное место под коммерческий объект, участок 1.4 га - 140 соток, (15 + 15 + 24.5 + 29.3 + 56.18 соток) с домом, подъезд к участку грунтовый, свет трёхфазный, вода родниковая, отличный обзор на Черногорский хребет, горы и гуцульскую столицу! На участке есть деревянный старый дом и хоз. постройки, сад. Мобильная связь - МТС, Киевстар, Life. Верховинский район горист, такой красоты вы нигде больше не встретите, он окружен бесконечными рядами хребтов и вершин, которые создают необычную своеобразную экзотику. Неподалеку находится школа рафтинга, горнолыжный трамплин и 2 бугельных подъемника 450м и 750м, церковь Пресвятой Троицы и деревянная Троицкая церковь- 1881г. Активный отдых - сбор грибов и ягод летом, катание на лыжах зимой, походы в горы и катание на лошадях целый год. Горнолыжные курорты Буковель – 65 км. Ворохта – 25 км. Быстрец – 10 км. Цена – 500у.е./сотка', 'Украина, Ивано-Франковская обл, Верховина', 'kD5L7hOwS1Q', 25, 2),
(105, 'Продам несравненный участок 50-га в Буковель', 'c.Поляниця, Буковель. Продам земельный участок 50га (5000 соток) сельскохозяйственного назначения, у Буковеля, красивый пейзаж. Прекрасный панорамный вид на Карпаты. Идеально подходит для строительства санатория или огромного оздоровительно-гостиничного комплекса!', 'Поляница, Ивано-Франковская область, Украина', '6yUBIL4irzE', 31, 2),
(93, 'Предлагаю 2 дома и чудесный участок 8-га под имение в Карпатах, дешево', 'Верховина, Замагора, 8 га (800 соток), два дома, свет, вода, рядом лес и река, заезд на участок круглогодичный! Очень красивый вид на Черногорский хребет и вокруг! Отличное место под коммерческие объекты! Верховинский район горист, такой красоты вы нигде больше не встретите, он окружен горами Поп Иван, Пушкар, Ледескул, Змиинська Велика, Великий Погар, Малый Погар, Магурка, Копилаш, Писаний Каминь, Синицы, Красник, Била Кобыла, Ребра, Жовнирська, Билинчукив Верх, Бребенескул, Вухатий Камень, Смотрич, Дземброня, Васкуль, Мунчел, Керничний, Шпыци, Велика Маришевська, Кострич, Гига, Костриця, Стиг, Кострич, Скупова,Тарниця, Баба Лудова, Велика Будийовська, Чивчин, Коман, Лостун, Пирье, Штивьора, Каменець, Крента Верхня, Крента Нижня, Грегит, Ротило, Чорний Грунь, Игрець, Роги. Ряд хребтов и вершин, создают необычную своеобразную экзотику. Рядом находится школа рафтинга, горнолыжный трамплин и 2 бугельных подъемника 450м и 750м, церковь Пресвятой Троицы и деревянная Троицкая церковь- 1881г. Активный отдых - сбор грибов и ягод летом, катание на лыжах зимой, походы в горы и катание на лошадях целый год.', 'Украина, Ивано-Франковская область, Верховина', 'GsGv8kP3CEU', 33, 2),
(95, 'Фантастический коттедж 140м2, где снимали фильм 2013г. ', 'Предлагаю фантастический коттедж 140 м2 в Верховине, где снимали фильм 2013 г. \"Тени незабытых предков\". Не путать с \"Тени забытых предков\" 1965 года.\nУчасток под домом 11-соток, коммуникации, речка, отличный подъезд к территории! Паровое отопление, дорогой двухконтурный камин с насосом пускает тепло по батареям, электрическая плита. По соседству можно докупить 22-сотки! Место очень красивое и фантастическое! Вся Верховинская область, прекрасная как для отдыха, так и для постоянного проживания для тех, кто решил сохранить здоровье, попить животворящую, природную воду, подышать воздухом, которое придает силы. Верховина - гуцульская столица. Здесь очень развит туризм! Инвестиции в Карпаты – это инвестиции в своё здоровье, в здоровое будущее своих детей, возможность дышать свежим воздухом и пить чистую живую воду! Приобретая дома и земельные участки в Карпатах, Вы получаете взамен кусочек первозданной природы! Земля находится в регионе, включенным в заявку Украины на проведение зимней Олимпиады 2022 года. Под эти цели правительством страны уже разработана специальная программа. Если Вы привыкли действовать, а не рассуждать – позвоните мне уже сейчас! Путешественник и специалист по инвестициям - Александр Ткаченко', 'Верховина, Ивано-Франковская область, Украина', '4Tph4p4ZT-A', 25, 2),
(96, 'Срочная продажа великолепного участка 50 соток в Карпатах, за символическую цену!', 'Срочно в хорошие руки и добрые сердца, отдаю дешево великолепный участок 50 соток!\nДземброня (Берестечко), имеет статус горного населенного пункта, который расположен на территории 843 га, имеет протяженность 10км. В день летнего солнцестояния на горе Вухатый каминь, расположенной неподалеку деревни, мольфары приносили жертву богам. С давних времен живописная Дземброня, привлекает к себе внимание. Здесь бывали и творили известные писатели Леся Украинка и Василий Стефаник. Именно урочище Дземброня вдохновило художника и режиссера с мировым именем Сергея Параджанова на съемки самой известной украинской киноленты \"Тени забытых предков\".\nЗдесь сохранилась древняя культура, самобытные национальные традиции, уникальные обычаи и обряды, которые по-своему способствуют развитию туристического потенциала региона. К юго-западу от села на потоке Мунчель (впадает в реку Дземброню) можно увидеть каскады водопадов, которые называются Дзембронськие (другой вариант - Смотрицкие). Общая высота перепада воды - около 100м, высота самого высокого каскада - 10м. С долин Степанский и Косарище, расположенных к северу над деревней, открывается живописный вид Черногорского хребта. Дземброня – это начало пешеходных маршрутов на Черногорский хребет.\nПутешественник и специалист по инвестициям - Александр Ткаченко', 'Берестечко, Верховинский район, Ивано-Франковская область, Украина', 'iHfg9wloN7w', 31, 2),
(97, 'Верховина, центр, новый дом 140м2, с мебелью, 100% - готовности в Карпатах!', 'Верховина - гуцульская столица. Новый дом 140м2, с мебелью, 2-этажа, 100% - готовности, срочно, дешево! Отопление на калориферах, плита – электрическая плюс газовая! Здесь очень развит туризм! Инвестиции в Карпаты – это инвестиции в своё здоровье, в здоровое будущее своих детей, возможность дышать свежим воздухом и пить чистую живую воду! Приобретая дома и земельные участки в Карпатах, Вы получаете взамен кусочек первозданной природы! Если Вы привыкли действовать, а не рассуждать – позвоните мне уже сейчас!', 'Верховина, Ивано-Франковская область, Украина', 'i-Wt2K3i9Js', 25, 2),
(117, 'Продажа дома 120м2 в прекрасном месте Карпат, с.Пистынь', 'Косов, c.Пистынь, дом-120м2 / 80м2, дерево и кирпич, 40 соток земли, есть два дома номер каждого в отдельности. Дома имеют хороший асфальтовый заезд, идеально подходят как под дачное, так и для постоянного жилья. Территория находится над рекой \"Пистинька\", с другой стороны лес. В дом проведен газ, также печное отопление, заезд с асфальта, есть колодец, конюшня, навес. К курортному села Шешоры 4 км.', 'Пистынь, Косовский район, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 25, 2),
(118, 'Продажа участка 20 соток под базу отдыха в г. Косов, Карпаты', 'Косов, ул. Над Гуком. участок 20-соток, рядом горная река-40м, лес, туристическая база отдыха Байка, Лечебно-оздоровительный комплекс Карпатские зори. Вид с земельного участка на гору Михалкова (Горнолыжный курорт). Расстояние до Ивано-Франковска 100км, до Буковель 95км. На участке есть маленький старая хижина, колодец (вода) газ, свет!', 'ул. Над Гуком, Косов, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 31, 2),
(119, 'Продажа действующей гостиницы 930м2 в Поляница, Буковель', 'Отель построен из дикого сруба по древней технологии, ручная работа. Гостиница действующая, открылась в ноябре 2011 года. Находится в селе Поляница, урочище Стаище, в 2 км от ТК «Буковель», 50м от центральной дороги. Участок - 13 соток в собственности. Общая площадь постройки - 930 кв.м. За сутки принимает 94-96 человек. Номерной фонд - 22 номера. Люкс - 5 номеров, (трехкомнатные), на 6-8 человек. Полулюкс - 9 номеров, (двухкомнатные), на 2+2 человека, улучшенный стандарт - 3 номера, (однокомнатный), на 2+2 человека. Стандарт - 5 номеров, (однокомнатный), на 2 человека. В каждом номере есть фен, сейф, ЖК-телевизор, мини-кухни с холодильником и микроволновой печью (только в люксах). Ресторан полностью оборудован современной техникой и посудой. Своя трансформаторная подстанция на 100 кВт. Своя котельная на твердом топливе.', 'ул. Карпатская, Поляница, Ивано-Франковская область, Украина', 'k5Nx27WUAUI', 11, 2),
(120, 'Продажа коттеджа с мебелью 132м2 в Карпатах, Микуличин', 'Продам коттедж 132м2 в Карпатах – село Микуличин. Год застройки 2011. Введен в эксплуатацию, имеются все документы. Строился для себя. Стены - газобетон, снаружи фальшбрус, изнутри - вагонка. Площадь участка - 5 соток. Дорога -асфальт 2,3км от центральной дороги. Территория ограждена, есть охрана. До Буковеля 28км, до Яремче 15 км. Описание: гараж, кухня полностью оборудована, гостиная с камином, 4 спальни, два санузла с душевыми кабинами, два бойлера, стиральная машина, своя скважина, отопление электрическое, спутниковое ТВ, электросчетчик 3-х фазный, два тарифа (дневной и ночной -50%). Остается вся мебель и техника.', 'Микуличин, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 29, 2),
(100, 'Продається відпочинковий комплекс 412м2 в с.Микуличин', 'Продається відпочинковий комплекс в с.Микуличин, Яремчанської міськради. Приватизована земельна ділянка 31 сотка. Дерев\'яний двоповерховий котедж загальною площею 412 м2: 1 поверх - вітальня-їдальня з каміном та барною стійкою\n(м\'яка частина, плазмовий телевізор), номер люкс. 2 поверх - 4 номери люкс та 2 номери півлюкс. Люкс - двокімнатний номер, вітальня (диван, телевізор, шафа для одягу, стіл та стільці), спальня (двоспальне ліжко), санвузол (душова кабіна, туалет, умивальник). Півлюкс — двоспальне ліжко, телевізор, шафа для одягу, санвузол (душова кабіна, туалет, умивальник).\nДерев\'яний двоповерховий будинок: 1 поверх - сауна на 6 осіб з контрастним басейном та масажним ліжком, 2 поверх - два номери півлюкс. На облаштованій території є альтанки та мангал. Поруч - річка, в якій влітку можна купатися. Опалення: автономне водяне. Водопостачання: холодна та гаряча вода постійно, котел на дровах, трансформатор на 40 квт, скважина. До гірськолижного курорту Буковель - 18 км, до Яремче - 12 км.\nМикуличин - низькогірний кліматичний курорт, розташований у долині річки Прута. Найдовше село в Україні, загальна протяжність - 44 км. Землі, на яких розкинулося село, колись належали Галицькому князівству. Князь Данило Галицький ними нагородив князя Микулу. В середині XIII ст. в Карпатах було збудовано декілька сторожових постів, серед них і Микулин пост, який згодом став великим населеним пунктом. У селі збереглися дерев\'яні (здебільшого під бляхою) Троїцька церква з дзвіницею (1863).', 'Микуличин, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 11, 2),
(116, 'Продажа дома 110м2 в прекрасном месте Карпат, Косов', 'Косов, ул. Над Гуком, дом 2-этажа, есть мансардный этаж, 110 м2, 5 комнат, тип стен: дерево и кирпич, газ и свет в доме, участок земли - 16 соток, сад, баня, вода автоматическая с колодца, отопление газовое, подогрев воды- колонка, канализация - септик, душевая кабина, газовая плита, холодильник, счетчик на электричество, счетчик на газ.', 'ул. Над Гуком, Косов, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 25, 2),
(101, 'Продается земельный участок 85 соток в Буковель возле подъемника', 'Продается земельный участок 85 соток в с. Поляница (Буковель) урочище Вишня. Целевое значение - строительство. Идеально подходит для строительства гостиничного комплекса. ГК Буковель, живописный вид, возле участка в 70м асфальтированная дорога, электричество, до подъемника №7 – 320м.', 'ур. Вишня, Поляница, Ивано-Франковская область, Украина', '6yUBIL4irzE', 34, 2),
(102, 'Продается земельный участок 37 соток в Буковель возле 1-го подъемника', 'Продам земельный участок 36,7-соток под строительство в Буковеле. Прекрасный панорамный вид не только на Карпаты, но и весь горнолыжный курорт «Буковель». 300 м до первого подъемника ТК «Буковель». Удобный заезд. Одна из двух подъездных дорог асфальтирована. Коммуникации рядом. На участке есть колодец с родниковой водой. Имеются все необходимые документы.', 'ур. Вишня, Поляница, Ивано-Франковская область, Украина', '6yUBIL4irzE', 33, 2),
(103, 'Продаются 2 дома 200м2, на безумно-красивом месте в Яремче', 'Очень крутой вид на горы! Продаются два дома 2007 года, 200м2, на одной большой территории 22 сотки, возможна достройка еще двух домов. Возможна продажа каждого дома отдельно: 1буд. 100м2 и 10 сот. земли – 120.000у.е.; 2буд. 100м2 + подвал и 10 сот. земли – 130.000у.е. Частная закрытая парковка. Есть своя вода (колодец и скважина). 100% готовность домов. проведен интернет. Действующий бизнес. От центральной дороги к территории 400м., за домами 100м лес.', 'ул. Ивана Франко, Яремче, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 25, 2),
(104, 'Продается хозяйство с роскошным земельным участком 400 соток в Верхний Ясенов', 'Продается хозяйство 67м2 сруб, 2-комнаты, с роскошным земельным участком 4-га (400 соток) в Ивано-Франковская область, Верховинский район, с. Верхний Ясенов. Хороший живописный вид на горы, свет, вода, летом: грибочки, черники, ягоды, малины. Вблизи Писаный Камень (историческое место Гуцульщины) - 1км, до центра с.Ясенов - 4км. Проезд до места с 3 сторон.', 'Верхний Ясенов, Ивано-Франковская область, Украина', 'uJvAU8iUt8', 33, 2),
(107, 'Предлагаю лучшие участки в Карпатах', 'Продам земельные участки различной величины в различных уголках Карпат, Яремче, Буковель, Микуличин, Татаров, Ворохта, Яблуница, а также самого прекраснейшего по своей природе и красоте Верховинского района, не дорого, в наличии все необходимые документы, смена целевого назначения, помощь по строительству, помощь с ведением бизнеса в Карпатах. Постоянно срочные новинки в продаже! Внимание - многое даже не доходит до рекламы!', 'Яремче, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 34, 2),
(108, 'Прекрасный под коммерцию участок 44 сотки в Буковеле', 'Продается земельный участок 44 сотки под застройку в с. Поляница, 1200м от первого подъемника, возле гостиницы Калина. Заезд с двух сторон. Постоянно срочные новинки в продаже! Внимание - многое даже не доходит до рекламы!', 'Поляница, Яремчанский район, Ивано-Франковская область, Украина', '6yUBIL4irzE', 34, 2),
(109, 'Продажа дома 120м2 в Карпатах с видом на Черногорский хребет', 'Ильцы, Верховинский р-н, Ивано-Франковская обл. Продается коттедж 120 м2 с оцилиндрованного бруса размером 8 х 8 метра, расположенного на участке площадью 13 соток в центре поселка. Внизу коридор, кухня, гостиная (есть лестница), санузел, котельная, проведено свет, канализация. Есть документы о вводе в эксплуатацию. Сверху три отдельные комнаты, два балкона, коридор. С участка в ясную погоду можно увидеть Черногорский хребет.', 'Ильцы, Верховинский район, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 29, 2),
(110, 'Продается коттедж 160м2 в Татарове, Карпаты', 'Продается коттедж в Татарове, Яремчанского района, Ивано-Франковской области в 15км от Буковеля. Коттедж двухэтажный сруб, построенный в 2007 году, площадью 160м, 5-комнат, 4 спальни по 16м2 и 2 санузла, сауна. Обогрев - электроконвектора. Вода подается из скважины через систему очистки и умягчения, а для приготовления пищи - через систему обратного осмоса. Земельный участок 8,18 соток. Двор вымощен ФЭМами, засажен елками (4-5м высотой), туями (3-4м) и множеством разных кустарников, цветов и других растений. Во дворе находится альтанка 43м2 с мангалом. Цена договорная.', 'Татаров, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 29, 2),
(111, 'Готовый комплекс из трех зданий в Карпатах, Татаров', 'Ивано-Франковская область, c.Татаров. Готовый коттеджный комплекс из трех зданий, расположен в живописном месте на берегу реки Прут (100м от центральной автодороги Н09). Коттедж общая 235м², жилая 155м², кухня 20м², 2-этажа, комнат- 5, Участок: 8 соток, стены- газобетон, год постройки: 2010. Доехать до коттеджа возможно в любое время года - каменная дорога (равнина). Коттедж состоит из просторного холла с камином, кухни и гостевой комнаты. Есть три санузла с душевыми кабинами. Коттедж изнутри отделан деревом, снаружи- утепленный и оштукатуренный \"короедом\". На территории отдельно сведены сауна с комнатой отдыха (30м.кв.) с калиброванного сруба и гараж с гостевой комнатой-студией с кухней и сан.узлом. Есть также большая беседка и каменный мангал-барбекю. Водяное снабжение от собственной глубинной скважины, собственная трансформаторная подстанция на 100кВт, которая обеспечивает электроснабжение дома. Отопление - комбинированное (электрокалориферы, камин). Территория по периметру засажена плодовыми и хвойными деревьями.', 'ул. Независимости, Татаров, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 29, 2),
(112, 'Продажа коттеджа 300м2 в Карпатах, Микуличин', 'Ивано-Франковская область, с.Микуличин, от Буковеля 20км, коттедж 300м2, 3-этажа, 21 сотка, тип стен: дерево и кирпич, 12м х 12м, есть все документы, 6 жилых комнат с санузлами, электричество 380/220, отопление, вода, канализация, + вся мебель, + на территории есть еще одна недостроенная коробка небольшого коттеджа с окнами.', 'ул. Грушевского, Микуличин, Ивано-Франковская область, Украина', '9wfosj0G0Ew', 29, 2),
(113, 'Продам участок 20 соток под строительство Буковель', 'Ивано-Франковская, Буковель, с. Поляница, продажа участка 20-соток под жилую застройку, в самом центре туристического комплекса Буковель, 10 минут ходьбы от участка к подъемнику. СРОЧНО!', 'ул. Карпатская, Поляница, Ивано-Франковская область, Украина', '6yUBIL4irzE', 33, 2),
(114, 'Продам базу отдыха 213 м2 в Карпатах - Верховина', 'Коттедж находится в центре гуцульской столице - Верховина, в 100 метрах от центральной дороги, на берегу реки Черный Черемош, в живописнейшем месте. Построен по энергосберегающей технологии «Термодом» с идеальной тепло- и звукоизоляцией.\nОбщая площадь 213 кв.м + 5 балконов по 4.8 кв.м. Площадь участка –0,07га.\nФундамент – ж/б ленточный. \nСтены – монолитные ж/б в пенополистирольной «шубе» толщ 10см. \nПерекрытие – монолитное ребристое ж/б; высота этажа –3,00м. \nОкна, балконы – металлопластиковые, «под дерево». \nВодоснабжение – автономное (колодец, насосная).\nГорячее водоснабжение – каждый номер от индивидуального электробойлера.\nЭлектричество – 3х фазное, непосредственно от подстанции. \nКанализация – септик (дренажная система, биоочистка).\nОтопление - индивидуальное, с принудительной циркуляцией. 1-й этаж и все санузлы – подогрев полов, в комнатах – электроконвектора. \nПланировка:\n1-й этаж: холл, два 2-х местных номера (вместимость – 2 человека в каждый), каминный зал – ресторан, кухня, насосная, прачечная, су, сауна с отдельным входом, топочная.\n2-й этаж: холл, 2-х комнатный люкс (6 человек), 2 полулюкса (по 4 человека в каждый), служебная комната. \nВыход на балкон со всех номеров – в сторону реки и гор. Вид – уникальный.\nВ каждом номере – санузел, мебель, холодильник, телевизор (спутниковое ТВ). \nПокрытие полов (кроме комнат) – керамическая плитка. В комнатах – ковровое покрытие.\nУютный интерьер каминного зала, натяжной потолок.\nБлагоустройство:\n- ограждение: забор по периметру с фундаментом и каменными колоннами, дощатой обрешеткой;\n- стоянка для автомобилей;\n- въезд а/м и пешеходные дорожки выложены брусчаткой; \n- зеленые насаждения, скамейки;\n- ландшафтное освещение; \n- 3 беседки, мангал;\n- береговая линия укреплена габионами.\nК Вашим услугам все для активного отдыха: рядом – подъемник, трамплин, условия для рафтинга, а также вся инфраструктура районного центра – почта, магазины, аптеки, мед.учреждения.', 'Верховина, Ивано-Франковская область, Украина', 'ZxG2eL1ygXo', 18, 2),
(115, 'Продажа готового бизнеса 800м2 в Карпатах, Татаров', 'Коммерческий комплекс 800м2 в с.Татаров, готовый бизнес, 2-этажный, рассчитан на 12 номеров, и отдельный коттедж с сауной. Первый этаж дома со столовой, которая рассчитана на 25 мест. Татаров - низкогорный климатический курорт, расположенный в широкой долине реки Прут, на высоте 750м над уровнем моря. Первое упоминание о селе датируется XVIIIв. А уже в конце XIXв. Татаров - известный курорт. Здесь были свои виллы и приезжали каждое лето на отдых гости из Львова, Кракова, Варшавы, Вены.', 'Татаров, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 18, 2),
(121, 'Продажа коттеджа 200м2 в Карпатах, Микуличин', 'Яремча, c.Микуличин. Деревянный коттедж 200м2 из бруса 100%, 2-этажа, 5-комнат, 10-соток, 100% готовности \"под ключ\" с документами в 25 км. от ГК Буковель. Въезд с центральной дороги на ГК Буковель с автоматическими воротами. В доме 4 спальни, каминный зал, кухня, 3 с/у, котельная, две спальни на втором этаже имеют отдельные с/у и террасу с видом на речку и горы.', 'ул. Грушевского, Микуличин, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 29, 2),
(122, 'Продам земельный участок 80 соток под коммерцию на берегу реки в центре Верховины, Карпаты', 'Предлагаю великолепный участок 80 соток под коммерцию на берегу реки в центре Верховины, возле пляжа, с коммуникациями! Отличное место под коммерческие объекты! Верховинский район горист, такой красоты вы нигде больше не встретите, он окружен горами Поп Иван, Пушкар, Ледескул, Змиинська Велика, Великий Погар, Малый Погар, Магурка, Копилаш, Писаний Каминь, Синицы, Красник, Била Кобыла, Ребра, Жовнирська, Билинчукив Верх, Бребенескул, Вухатий Камень, Смотрич, Дземброня, Васкуль, Мунчел, Керничний, Шпыци, Велика Маришевська, Кострич, Гига, Костриця, Стиг, Кострич, Скупова,Тарниця, Баба Лудова, Велика Будийовська, Чивчин, Коман, Лостун, Пирье, Штивьора, Каменець, Крента Верхня, Крента Нижня, Грегит, Ротило, Чорний Грунь, Игрець, Роги. Ряд хребтов и вершин, создают необычную своеобразную экзотику. Рядом находится школа рафтинга, горнолыжный трамплин и 2 бугельных подъемника 450м и 750м, церковь Пресвятой Троицы и деревянная Троицкая церковь- 1881г. Активный отдых - сбор грибов и ягод летом, катание на лыжах зимой, походы в горы и катание на лошадях целый год. Цена - договорная!', 'Верховина, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 31, 2),
(123, 'Продажа участка 525 соток в Ужгороде, автомагистраль Чоп-Киев', 'Ужгород, р-н. Восточный, Окружная дорога, участок 525 соток, расположен на южной окраине Ужгорода, на фрагменте окружной дороги между селами Розовка и Кинчеш, что является частью автомагистрали Чоп-Киев, в 6 км от географического центра города, 8 км от словацкой границы, 20 км от венгерского границы и Чоп. Государственные акты с целевым назначением: (для строительства жилых домов на 4 га) и (для строительства супермаркета на прилегающие к дороге 1,25 га). Газ и свет - возможно подводки. Рядом - автобазар, 2 АЗС, железная дорога, промышленная зона. Ширина по фронту вдоль автомагистрали - 230 метров. Есть топографическая съемка территории. Перспектива использования: большой торгово-развлекательный комплекс, супермаркет стройматериалов, садового инвентаря и мебели, автозаправочный комплекс, мотель, автосалон и автосервис, логистический центр, промышленное предприятие, коттеджный городок.', 'Ужгород, Закарпатская область, Украина', 'QuJvAU8iUt8', 34, 2),
(124, 'Дом с живописным участком 195 соток в Шепот, Карпаты', 'Продается земельный участок в живописном с.Шепот, Косовского р-н, Ивано-Франковской область! Участок площадью 1.95га (195-соток), на ней расположен домик и молодой сад! Участок находится в горе Буковец, от центральной дороги 2 км! Земля достаточно плодоносящая, так что она может быть, как под садоводство, так и под застройку небольшой туристической базы! Не далеко от земли, расположена канатная дорога в с.Шешоры! Цена- договорная!', 'Шепот, Косовского район, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 33, 2),
(125, 'Продажа домика 40м2 на горной долине в живописном месте Карпат, Кривополье', 'Домик 40 м2 на горной долине в живописном месте, 3-комнаты, участок- 20 соток. На этой территории, от прекрасного вида первоначальной природы захватывает дух! Вокруг тишина и покой, которыми можно насладиться и отдохнуть от повседневной суеты, войти в сказочную атмосферу и побыть наедине с природой!', 'Кривополье, Верховинский район, Ивано-Франковская область, Украина', 'NMbrSDiRy2Y', 25, 2),
(127, 'Строение 554 м2 на 1.7га под базу отдыха в гуцульской столице - Верховина', 'Строение под базу отдыха в гуцульской столице - Верховина. Площадь участка: 1,7 га. Возле базы отдыха, находится речка. По ген. плану 6 двухэтажных коттеджей и трехэтажный корпус, бани, водопад, форелевое озеро. Продажа по отдельности участков под строительство коттеджей. (можем построить по-вашему проекту) готовность первого 3-этажного корпуса 70% (коробка + крыша + перегородки) площадь первого корпуса-554 м2. Рядом есть горнолыжный подъемник. Развит Международный рафтинг. Хорошая подъездная дорога, на участке горный минеральный источник, живописное место, пологая горка для катания новичков. Рассмотрим все возможны варианты (продажа, инвестиции, обмен.)', 'Верховина, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 8, 2),
(128, 'Продажа дома 90м2 на 100 сотках земли в Карпатах, Шепот', 'Срочная продажа дома 90м2 с участком 1-га (100 соток), находится в с.Шепот, урочище Грунте, Косовского района. Рядом находится водопад \"Гук\" и гора Грегит. Возле дома есть конюшня, навес. Все документы готовы. Удаленность от города Косов - 25 км.', 'Шепот, Косовский район, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 25, 2),
(129, 'Продажа прекрасного домика 60м2 под дачу в Карпатах, Шепот', 'Прекрасный домик 60м2 в очаровательном месте, расположился на красивейшем земельном участке - 60 соток в с. Шепот, Косовского района. Недалеко находится водопад. Водопады - сила, которая создает красивые пейзажи, течет от одной скульптурной формы к другой. В карпатских водопадах есть свой шарм и по-своему хороши. У нас их полный набор - от высоких и полноводных до маленьких и уютных. От грохочущих до шепчущих. От одиночных до состоящих из сотен маленьких потоков. Путешественник, который задастся целью посетить их все, безусловно, рискует износить не одну пару обуви. Многие водопады находятся в труднодоступных местах, а к некоторым дороги ведут только на картах, а в реальности это скорее «направления». Зато каждый из них уникален, и они расположены в удивительных местах, которые словно трансплантировали в Карпаты из какой-то южной страны. Цена - срочная, договорная!', 'Шепот, Косовского района, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 25, 2),
(130, 'Продажа квартир небоскреб бизнес класса, Кловский спуск 7а', 'Продажа квартиры на Печерске в новом доме, Кловский спуск 7а. Площадь: от 83м2 до 557м2. Историческая и деловая часть Киева. Мариинский парк, Крещатик в 10 минутах ходьбы. Дом категории «Business». Самый высокий небоскреб бизнес класса в Украине, на Кловском спуске, 7-а. Панорамные виды, которые являются обязательным компонентом роскошного жилья в Нью-Йорке, Лондоне или Токио, теперь такая же неотъемлемая составляющая элитной недвижимости и в Киеве. Визит в Кловский сродни настоящей магии… Высоко среди облаков ничем не ограниченный обзор из огромных панорамных окон вдохновляет и возносит. Шум большого города остается далеко внизу, а Вы можете глубоко вдохнуть и дотянуться до звезд. Удобная транспортная развязка, развитая инфраструктура (рестораны, кафе, банки). В доме предусмотрена вертолетная площадка, двухуровневый паркинг, 5 высокоскоростных лифтов, современные инженерные системы, круглосуточная охрана, лобби, консьерж. Ключевой особенностью являются шикарные панорамные виды на Днепр, Родину-Мать, Киево-Печерскую Лавру, Зверинецкие холмы, которые открываются из окон апартаментов. Квартиры имеют большие площади, высокие потолки 3.2 м., функциональное зонирование, и витражное остекление. Права собственности в наличии. Есть варианты.', 'Кловский спуск, 7-а, Киев, Украина', 'OMRi3rV2s70', 27, 2),
(131, 'Продажа 1ком. квартир небоскреб бизнес класса, Кловский спуск 7а', 'Продажа квартиры на Печерске в новом доме, Кловский спуск 7а. Площадь: от 83м2 до 557м2. Историческая и деловая часть Киева. Мариинский парк, Крещатик в 10 минутах ходьбы. Дом категории «Business». Самый высокий небоскреб бизнес класса в Украине, на Кловском спуске, 7-а. Панорамные виды, которые являются обязательным компонентом роскошного жилья в Нью-Йорке, Лондоне или Токио, теперь такая же неотъемлемая составляющая элитной недвижимости и в Киеве. Визит в Кловский сродни настоящей магии… Высоко среди облаков ничем не ограниченный обзор из огромных панорамных окон вдохновляет и возносит. Шум большого города остается далеко внизу, а Вы можете глубоко вдохнуть и дотянуться до звезд. Удобная транспортная развязка, развитая инфраструктура (рестораны, кафе, банки). В доме предусмотрена вертолетная площадка, двухуровневый паркинг, 5 высокоскоростных лифтов, современные инженерные системы, круглосуточная охрана, лобби, консьерж. Ключевой особенностью являются шикарные панорамные виды на Днепр, Родину-Мать, Киево-Печерскую Лавру, Зверинецкие холмы, которые открываются из окон апартаментов. Квартиры имеют большие площади, высокие потолки 3.2 м., функциональное зонирование, и витражное остекление. Права собственности в наличии. Есть варианты.', 'Кловский спуск, 7-а, Киев, Украина', 'OMRi3rV2s70', 23, 2),
(132, 'Волшебный участок под Эко-городок в Карпатах на горе Пушкар', 'Гуцульская столица - Верховина, участок 1-га (100 соток) на горе Пушкарь, которая находится в центре самой Верховины, вид с участка на саму Верховину, Ильцы и Черногорский хребет. Известны Семь чудес Верховинщины: обсерватория на горе Поп Иван, геологическая памятка природы Писаный Камень, высокогорное озеро Маричейка, высокие скалы Шпицы, церковь Рождества Богородицы, Кладовые Довбуша на г.Синицы, скалы в парке Венгерское. Это место притягивает духовников и монахов своей вселенской тишиной и отсутствием суеты. Идеальное место под строительство коммерческих объектов! Свет и вода имеются! Срочная продажа! Возможно расширение!', 'Верховина, Ивано-Франковская область, Украина', 'hQe-HTeqajQ', 33, 2),
(133, 'Предлагаю коттедж 140 м2 в центре Ильцы, возле подъемника', 'Верховинский район, Ильцы, коттедж 140м2 в центре, возле подъемника, 13-соток земли, полный фарш от Wi-Fi до кондиционеров и видеонаблюдения! Гараж, 2-душевые кабины, 1-ванная со всеми удобствами, 3-виды отопления: электрокотел, твердотопливный котел. На этой территории, от прекрасного вида первозданной природы захватывает дыхание: грациозные деревья с вечнозелеными лохматыми ветвями дремлют в утренней дымке, солнце радужно освещает застывшую в глубоком раздумье гору Говерлу. Если хотите ощутить приятный терпкий вкус красной бусинки-земляники или окрасить язык в синий цвет с помощью коварной черники, то немедля ступайте на лесную тропу. Здесь также будет, где разгуляться заядлому грибнику. Река Черемош, порадует профессионалов рафтинга, ведь здесь находится главный центр сплава по горным рекам! Вокруг тишина и покой, которыми можно насладится и отдохнуть от повседневной суеты, войти сказочную атмосферу и побыть сам на сам с природой!', 'Ильцы, Ивано-Франковская область, Украина', 'BzpZvbpWjA', 29, 2),
(134, 'Карпаты - великолепное имение на 4-га в Криворовне ', 'Продается хозяйство: старенький сруб, есть свет и вода, с роскошным земельным участком 4-га (400 соток) в Ивано-Франковская область, Верховинский район, с.Криворовня. Живописный вид на горы, летом: грибочки, черники, ягоды, малины. Вблизи г.Била Кобыла и г.Писаный Камень (историческое место Гуцульщины) - 1км. Проезд до места с 3 сторон. Это место притягивает духовников и монахов своей вселенской тишиной и отсутствием суеты. Ночи здесь дарят покой и умиротворение. Утро будит пением птиц. Когда вы распахнете свое окно на рассвете, вдохнете свежий воздух и энергию пробуждающейся природы, только тогда по-настоящему почувствуете себя живым.\nНе упустите свой шанс!', 'Криворовня, Верховинский район, Ивано-Франковской области, Украина', '0h3-zZYoBfw', 25, 2),
(135, 'Непревзойденный и волшебный участок 200-соток в Криворовня, Карпаты', 'Продажа приватизированного земельного участка 2 Га (200 соток), в живописном районе золотого кольца Украинских Карпат. Земля приватизирована, (наличие государственных актов). Участок находиться в Ивано-франковской области, Верховинского района, в поселке Криворовня, известном также как «Украинские Афины». Характеризуется очень выгодным месторасположением по отношению к горнолыжным комплексам, историческим памяткам и следовательно к большинству туристических маршрутов по Карпатам. Ближайшие отельные комплексы расположены на расстоянии 1000 м, рядом находится два активно работающих горнолыжных подъемника. На участок ведет дорога без твердого покрытия, подведено электричество. На территории есть ключи с родниковой водой, рядом горная речка. Участок находиться на возвышенности 780 м. над уровнем моря, имеет красивый панорамный вид во все стороны, и граничит с лесом. В районе 8км ведется капитальное строительство самого масштабного горнолыжного курорта Украины. Земля находится в регионе, включенным в предполагаемую заявку Украины на проведение зимней Олимпиады 2022 года. Под эти цели правительством страны уже разработана специальная программа, которой, в том числе, предлагается инвесторам выгодно вложить деньги в развитие регионов на хороших условиях.', 'Криворовня, Верховинский район, Ивано-Франковской области, Украина', 'QuJvAU8iUt8', 31, 2),
(136, 'Предлагаю действующий туристический бизнес 310 м2 в Верховине, Карпаты', 'Частная усадьба «Полонина» \"- действующий туристический бизнес, находится на юге Украинских Карпат и в центре Европейских Карпат. Усадьба расположена в нескольких километрах от центра пгт. Верховина (пгт. Верховина - 125 км к югу от г.Ивано-Франковска и 32 км к юго-востоку от пгт. Ворохта). Усадьба находится на горе Пушкарь, 2 км от трассы, рядом гора Магурка (1024 м). Самая высокая точка Украины - гора Говерла (2060 м) - находится на расстоянии 22 км от усадьбы, а горно-курортный комплекс Буковель - в 50км. Вокруг усадьбы - неповторимые пейзажи Карпат. Усадьба имеет 2 двухэтажных коттеджа (на 6 мест каждый). Коттедж стоят на горной долине, рядом лес. На дворе - 2 беседки, мангал, качели. Площадь земельного участка - 0.40 га. Общая площадь застройки составляет - 310м2, Коттедж № 1 - 110м2, Коттедж № 2 -110м2, Хозяйственный дом-баня, кухня - 90м2. Водоснабжение ключевой водой с помощью водяного насоса, вода подогревается электрическими бойлерами, отопление дома электрическое, коттеджи меблированы деревянной мебелью, сантехника импортная. ', 'Верховина, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 18, 2),
(137, 'Земельный участок 20 соток под строительство, в центре села Поляница, Буковель', 'Продается земельный участок 20 соток под строительство, в центре села Поляница, Буковель. Южный склон, солнечная сторона, отличное место для постройки отеля, развлекательного комплекса. Участок правильной формы, идеальный заезд, свет и вода на участке, красивый пейзаж, 200 м до первого подъемника. Участок напротив первого паркинга.', 'Буковель, Ивано-Франковская область, Украина', '6yUBIL4irzE', 34, 2),
(138, 'Прекрасный земельный участок 75 соток в Кривополье, Карпаты', 'c.Кривополье, Верховинского района, земельный участок 75 соток, красивый вид, вокруг леса, дикая природа. Линия электропровода. Есть план под застройку, раскопано место под строительство. К г.Говерле 8 км, до Буковеля 20 км, в Ивано-Франковск 90 км. Цена 7500у.е за 75-соток.', 'Кривополье, Верховинский район, Ивано-Франковская область, Украина', '7Dwsvo-wMMg', 33, 2),
(140, 'Участок 1.5 га, рядом крупное месторождение янтаря', 'Продается участок 1.5 га, относится к Белокоровичскому сельскому совету, Олевского района, Житомирской область.\nБелокоровичское лесное хозяйство, крупное месторождение янтаря, месторождение кварцитовидных песчаников и (выращивание, переработка леса, изготовление упаковочной продукции и шпал). Участок выходит на дорогу Н. Белокоровичи (военный городок - 500 м) - ж/д станция Н. Белокоровичи (800 м). Размеры участка: 299х54 м.  В 100 м от него, находится действующая артезианская скважина, которая обеспечивает питьевой водой военный городок. \n+38-096-768-83-76', 'Белокоровичи, Олевский район, Житомирская область, Украина', 'j3kWBhfGBk0', 32, 2),
(144, 'Продается 2-х этажный коттедж 160м2 в Микуличин, Карпаты', 'Срочная продажа 2-х этажного коттеджа 160м2 в Микуличин, изготовлен 1-этаж: блоки, второй: дерево. На первом этаже: зал, кухня, лестничная, спальня, ванная комната, котельная. На дугой повесить: три спальни, кухня, ванная комната. Электроснабжение (трехфазная система), котел на дровах, бойлер, колодец, канализация. Асфальтированный подъезд. Школа, садик, магазины - 500-800 метров от дома!\nМикуличин - это низкогорный карпатский курорт, расположенный в долине р Прут, находится на территории Карпатского природного национального парка на высоте 750 м над уровнем моря, а значит красота нетронутой природы царит повсюду в регионе. Относится Микуличин к Яремчанскому городскому совету, Ивано-Франковской области. Самое длинное село в Украине - его протяженность составляет 44 км - ведет свою историю еще с XV в. Водопад Женецкий Гук, расположен на высоте 900 м над уровнем моря, вода свободно падает с высоты 15м, а также прекрасен водопад «Капливець» на реке Прутец Чемиговський. Мягкий климат, карпатские луга, хвойные леса, река с тихой заводью (лучше подходящим для купания), горы - все это привлекает к себе не только горнолыжников, но и семейных туристов, и отдыхающих с заболеваниями легких. Хрустальный горный воздух, обладает антибактериальными свойствами благодаря соснам, что поят его своим терпким ароматом. А для семей, здесь много пеших экскурсий и походов, также прогулки за ягодами и грибами - для любого возраста и физической подготовки.', 'Микуличин, Ивано-Франковская область, Украина', 'QuJvAU8iUt8', 25, 2),
(145, 'Продажа дома 160м2 в Микуличин, Карпаты', 'Микуличин - это низкогорный карпатский курорт, расположенный в долине р Прут, находится на территории Карпатского природного национального парка на высоте 750 м над уровнем моря, а значит красота нетронутой природы царит повсюду в регионе. Относится Микуличин к Яремчанскому городскому совету, Ивано-Франковской области. Самое длинное село в Украине - его протяженность составляет 44 км - ведет свою историю еще с XV в. Водопад Женецкий Гук, расположен на высоте 900 м над уровнем моря, вода свободно падает с высоты 15м, а также прекрасен водопад «Капливець» на реке Прутец Чемиговський. Мягкий климат, карпатские луга, хвойные леса, река с тихой заводью (лучше подходящим для купания), горы - все это привлекает к себе не только горнолыжников, но и семейных туристов, и отдыхающих с заболеваниями легких. Хрустальный горный воздух, обладает антибактериальными свойствами благодаря соснам, что поят его своим терпким ароматом. А для семей, здесь много пеших экскурсий и походов, также прогулки за ягодами и грибами - для любого возраста и физической подготовки.', 'Микуличин, Ивано-Франковская область, Украины', 'QuJvAU8iUt8', 25, 2),
(146, 'Продажа дома 100м2 в Яремче, Карпаты', 'Яре́мче (до 2006 года - Яремча), город областного значения в Ивано-Франковской области Украины. Расположен в долине реки Прут, на высоте 585 метров над уровнем моря. По данным переписи 2001 года в Яремче проживало 7850 человек. До Ивано-Франковска по железной дороге - 54 км, по автодорогам - 62 км. В состав Яремченского горсовета входят сёла Вороненко, Микуличин, Поляница, Татаров, Яблоница и пгт Ворохта. Яремче — известный низкогорный климатический и горнолыжный курорт, центр туризма и отдыха на Прикарпатье. Город окружен горами, которые на севере и юге переходит в живописные холмы, покрытые густыми хвойными и лиственными лесами. Здесь расположены многочисленные санатории, в том числе для больных туберкулёзом легких, дома отдыха, туристические базы и гостиницы. Через Яремче протекает река Прут, в черте города присутствуют два водопада — «Пробой» и «Девичьи слёзы». В горных потоках водится ручьевая форель. Почвы в окрестностях Яремче в основном дерново-подзолистые, выше 1200-1400м. — бурые горно-лесовые, на высоте 1500-1600м — серо-бурые, выше 1600м — горно-луговые. Город расположен на автотрассе Ивано-Франковск — Рахов — Ужгород. Железная дорога связывает город с областным центром и Львовом.', 'Яремче, Ивано-Франковская область, Украина', '9wfosj0G0Ew', 25, 2);
INSERT INTO `offers` (`id`, `title`, `description`, `location`, `video`, `category_id`, `owner_id`) VALUES
(147, 'Продажа дома 200 м2 в пгт.Верховина, Карпаты', 'Верховина, ул. Грушевского. Продается незавершенный 2-х этажный дом (1й-кирпич, 2й -дерево), площадь 200 м2 на земельном участке 20 соток, в лес - 400 м, до зарыбленного ставка - 100 м, до реки Черный Черемош 50м (рафтинг), до канатной дороги 3км. Наряду построенные туристические дома, хижина. Говерла - 30 км, горнолыжный курорт Буковель - 60 км.', 'Верховина, Ивано-Франковская область, Украина', '5BzpZvbpWjA', 25, 2),
(165, 'Продажа земельного участка 10 соток в Ворохта, Карпаты', 'Ивано-Франковская область, пгт. Ворохта, ул. Грицуливка. Продажа земельного участка площадью 10 соток под строительство. Участок находится на уютной поляне у леса и источника, очень красивые пейзажи Карпат с целебным горным воздухом. Весь пакет документов. Цена - договорная!', 'ул. Грицуливка, Ворохта, Ивано-Франковская область, Украина', '', 33, 2),
(166, 'Продажа земельного участка 5 соток в Поляница, Буковель', 'Поляница, урочище Вишня, земельный участок 5-соток под строительство, 1 км от второго подъемника, коммуникации присутствуют, кадастровый номер: 2611092001:22:002:0441', 'Буковель, Ивано-Франковская область, Украина', '6yUBIL4irzE', 33, 2),
(167, 'Продается земельный участок 21 сотка для объектов отдыха и здоровья в г. Яремче', 'Яремче 22 сотки под строительство. Подъезд к участку. Свет, вода, газ. Участок граничит с лесом. Участок находится на возвышении с которой открывается красивый вид на реку и Яремче. Государственный акт под строительство жилого дома и хозяйственных сооружений. Помогу в строительстве деревянного коттеджа.\nЯремче - край живописных горных пейзажей, звонки водопадов и звуков трамбуют. Это земля гуцулов, которая долгие годы была отрезана от внешнего мира горными хребтами. Здесь, между нетронутой природы, скрывается целый особый вселенная с его причудливым смешением христианства и язычества, святых и нимф с Чугайстра. Яремче было одним из любимых мест отдыха для многонациональной аристократии из империи. Князья семьи из Вены, Кракова, Львова приезжали сюда ради Карпатской экзотики и бескрайней дикой природы. Особенно интересными для посетителей были местные жители - гуцулы.', 'Яремче, Ивано-Франковская область, Украина', '', 33, 2),
(150, 'Продам земельный участок 14 соток в Яремче, Карпаты', 'Яремча, ул. Горная, участок 14-соток, 10-строительство, 4-ОСГ. находится на окраине г. Яремча (через реку уже село Микуличин). Свет 10м, газ -80м, люди делают колодцы, источник мин.воды – 200м. Водопад «Капливець» - 200м. Прекрасное место для жилого дома, мини-отеля. Первая линия к Прут. К участку есть два подъезда, верхний и нижний. Асфальтированная дорога и щебень по 80м. Кадастровые номера: 2611000000:03:008:0094  и 2611000000:03:008:0093 \nЯремче (до 2006 года - Яремча), город областного значения в Ивано-Франковской области Украины. Расположен в долине реки Прут, на высоте 585 метров над уровнем моря. По данным переписи 2001 года, в Яремче проживало 7850 человек. До Ивано-Франковска по железной дороге - 54 км, по автодорогам - 62 км. В состав Яремченского горсовета, входят сёла Вороненко, Микуличин, Поляница, Татаров, Яблоница и пгт Ворохта. Яремче — известный низкогорный климатический и горнолыжный курорт, центр туризма и отдыха на Прикарпатье. Город окружен горами, которые на севере и юге переходит в живописные холмы, покрытые густыми хвойными и лиственными лесами. Здесь расположены многочисленные санатории, в том числе для больных туберкулёзом легких, дома отдыха, туристические базы и гостиницы. Через Яремче протекает река Прут, в черте города присутствуют два водопада — «Пробой» и «Девичьи слёзы». В горных потоках, водится ручьевая форель. Почвы в окрестностях Яремче в основном дерново-подзолистые, выше 1200-1400м. — бурые горно-лесовые, на высоте 1500-1600м — серо-бурые, выше 1600м — горно-луговые. Город расположен на автотрассе Ивано-Франковск — Рахов — Ужгород. Железная дорога связывает город с областным центром и Львовом.', 'ул. Горная, Яремче, Ивано-Франковская область, Украина', '9wfosj0G0Ew', 33, 2),
(151, 'Продажа земельного участка 14,26 соток под строительство в Яремче, Карпаты', 'г. Яремча по ул. Петраша, между турбазой \"Гуцульщина\" и \"Карпаты\", напротив мотеля \"Станиславский\", участок 14,26 соток под строительство, ровный, хороший подъезд, электричество на участке, газ - 10м, канализация-централизованная. Кадастровый номер участка: 2611000000:04:001:0067\nЯремче (до 2006 года - Яремча), город областного значения в Ивано-Франковской области Украины. Расположен в долине реки Прут, на высоте 585 метров над уровнем моря. По данным переписи 2001 года, в Яремче проживало 7850 человек. До Ивано-Франковска по железной дороге - 54 км, по автодорогам - 62 км. В состав Яремченского горсовета, входят сёла Вороненко, Микуличин, Поляница, Татаров, Яблоница и пгт Ворохта. Яремче — известный низкогорный климатический и горнолыжный курорт, центр туризма и отдыха на Прикарпатье. Город окружен горами, которые на севере и юге переходит в живописные холмы, покрытые густыми хвойными и лиственными лесами. Здесь расположены многочисленные санатории, в том числе для больных туберкулёзом легких, дома отдыха, туристические базы и гостиницы. Через Яремче протекает река Прут, в черте города присутствуют два водопада — «Пробой» и «Девичьи слёзы». В горных потоках, водится ручьевая форель. Почвы в окрестностях Яремче в основном дерново-подзолистые, выше 1200-1400м. — бурые горно-лесовые, на высоте 1500-1600м — серо-бурые, выше 1600м — горно-луговые. Город расположен на автотрассе Ивано-Франковск — Рахов — Ужгород. Железная дорога связывает город с областным центром и Львовом.', 'ул. Петраша, Яремче, Ивано-Франковская область, Украина', '9wfosj0G0Ew', 33, 2),
(156, 'Продам земельный участок 200 соток в Карпатах, Кривопольский перевал', 'Кривополье, Кривопольский Перевал, земельный участок 200 соток под индивидуальное строительство. Участок с видом на Говерлу! Окружен молодым грибным лесом!  На участке, чистейший источник воды и электричество! Подъезд к участку хороший! Удалённость от города 5 км.', 'Украина, Иванно-Франковская область, Кривополье', '7Dwsvo-wMMg', 33, 2),
(157, 'Продам земельный участок 18 соток в Карпатах, Ильцы', 'Продам земельный участок 18 соток в Ильцы, 4-х км от районного центра Верховина, рядом от центральной дороги. Участок расположен на ровной поверхности, у подножия горы Погар. Очень живописная местность. Из всех сторон окружена горными хребтами. У края участка является ров для дренажа и проходит дорога (по документам). Через участок также проходит линия электропередач. Часть соседних участков - застроены. В 300 м от земельного участка, течет река Черный Черемош. В селе есть горнолыжный спуск на 800м. Расстояние до Буковеля 47км, до Говерлы и горы Поп Иван около 35 км. ', 'Украина, Ивано-Франковская область, Верховинский р-н, Ильцы', '', 33, 2),
(158, 'Продажа участка 100 соток под жилую застройку в Карпатах, Верховина, Замагора', 'Продажа участка 100 соток под жилую застройку, Ивано-Франковская, Верховина, c.Замагора. Земля в Карпатах, красивые виды, 7км до Верховины, 50км до Буковеля, через участок проходит электросеть. ', 'Украина, Ивано-Франковская, Верховина', '', 33, 2),
(159, 'Продам коттедж 100м2 в тихой местности Карпат, Кривополье', 'Коттедж 100м2 расположен в тихой местности Карпат, на окраине с. Кривополье, 250м до центральной дороги, участок- 6 соток огражден забором, подъезд к дому, рядом лес, есть возможность докупить 12-соток земли. 2 этажа, 3 спальных комнаты, 1 гостиная с кухней, большой коридор, 2 санузла (душ кабина), 2 балкона, все комнаты полностью меблированы, спутниковое телевидение. Каменные дорожки по всему участку, есть беседка с мангалом, крыша - металлочерепица, ленточный фундамент обложен камнем, металлопластиковые окна, электричество (собственный трансформатор), канализация (септик), водоснабжения (колодец), отопление - электрические конвектора, камин. (18км - Верховина, 18км - Ворохта, 38км - Буковель).', 'Кривополье, Верховинский район, Ивано-Франковская область, Украина', '', 29, 2),
(160, 'Продажа коттеджа 190м2 в Карпатах, Ильцы', 'Ивано-Франковская, Верховина, Ильцы, 2-х этажный коттедж (сруб) 2015 постройки, 190м2/152/11-кухня, 6-комнат, 2-санузла, котельная / бойлерная, холл, гостиная, столовая, прихожая, 3-балкона, участок - 15 соток. Камин, счетчик на электричество, крыша - металлочерепица, подогрев полов, стяжка, дощатый пол, наружная отделка: окрашено (покраска) внутренняя отделка: деревянная вагонка, отделка потолка- деревянная вагонка, двери и окна - металопластиковые, защита окон - решётки, на территории есть непосредственный выход к водоему, персональный водоем- ручей, дорожки- натуральный камень, стоянка для автомобилей, забор- деревянный, ворота- КПП, отягощающие обстоятельства: самострой, вода: автоматическая с колодца, подогрев воды: бойлер отопление: твердотопливный котел, печное.', 'Ильцы, Верховинский район, Ивано-Франковская область, Украина', '', 29, 2),
(161, 'Продажа 2-х этажного дома 90м2 в Карпатах, Верхний Ясенов', 'Продажа 2-х этажного дома 90м2, Ивано-Франковская, Верховинский район, Верхний Ясенов, Ровня. Год постройки 2014, 2-этажа, 4-комнаты, 90 / 53 / 13.4, участок - 12 соток. Полностью жилой дом, зимой очень теплый. Отопление электрическое подведена 3 фазы 16 кВт. Счетчик день-ночь. Есть колодец, септик, в доме -санузел, (также есть туалет на территории.) Душевая кабина, бойлер, продается со всей мебелью и бытовой техникой (холодильник, морозильник, микроволновка, телевизор-плазма, тюнер, электроплита и т.п.). На территории есть гараж и летне-зимняя комната на 3 человека с мебелью и печкой. Территория огорожена, подъезд любым авто. Близко горы, река, магазины. Все условия для жизни.', 'Верхний Ясенов, Верховинский район, Ивано-Франковская область, Украина', '', 25, 2),
(162, 'Продается земельный участок 50-соток (25+25), под строительство в Карпатах, Поляница', 'Продается земельный участок 50-соток (25+25), под строительство в Поляница, Ивано-Франковская область. Второй ряд от центральной сельской дороги, хороший подъезд, рядом линия электросети, солнечная сторона. Расстояние до ТК Буковель 4 км.', 'Поляница, Ивано-Франковская область, Украина', '6yUBIL4irzE', 33, 2),
(163, 'Продажа участка 25 соток в Буковелье на первой линии, перед первым паркингом', 'Ивано-Франковская область, Буковель, Вышни. Продажа участка 25 соток, 1-я линия, фасад, перед первым паркингом, под строительство, есть план по строительству ресторана и гостиницы, рядом Отель-пиццерия «Монисто» - Hotel Monysto, над участком проходит трасса, на участке есть канализация и трансформатор.', 'Буковель, Ивано-Франковская область, Украина', '6yUBIL4irzE', 34, 2),
(164, 'Продажа земельного участка 1-я линия, фасад, в Поляница, Буковель', 'Буковель, Поляница, участок 56 соток (возможно от 20-соток) под строительство, 1-я линия от дороги на Буковель, фасад, район «Перевернутого Домика». Участок ровный, задняя часть выходит на реку, не затопляемый, до первого подъёмника 5-минут, напротив строится 3-подъёмника и коттеджный городок на 100 домов. ', 'Буковель, Ивано-Франковская область, Украина', '6yUBIL4irzE', 34, 2);

-- --------------------------------------------------------

--
-- Структура таблицы `paidOffers`
--

CREATE TABLE `paidOffers` (
  `id` int(11) NOT NULL,
  `offer_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `paidOffers`
--

INSERT INTO `paidOffers` (`id`, `offer_id`) VALUES
(1, 9),
(2, 13),
(3, 11),
(4, 17);

-- --------------------------------------------------------

--
-- Структура таблицы `posts`
--

CREATE TABLE `posts` (
  `id` int(11) NOT NULL,
  `title` varchar(1024) NOT NULL,
  `content` varchar(16384) NOT NULL,
  `author_id` int(11) NOT NULL,
  `date` datetime NOT NULL,
  `image` varchar(1024) NOT NULL,
  `views` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `posts`
--

INSERT INTO `posts` (`id`, `title`, `content`, `author_id`, `date`, `image`, `views`) VALUES
(2, '«Голландські» аукціони в Україні ', '31 серпня 2015 року в Україні відбудуться торги у форматі голландського аукціону. \n «Голландськими» називають аукціони, що здійснюють торги за методом зниження ціни.  Метою таких аукціонів є позбавлення від дрібної власності, яку держава не може ефективно використовувати.\nНа сьогоднішній день в Україні вже є законодавча база, що дозволяє влаштовувати аукціони за методом зниження ціни. \nОсобливості голландського аукціону:\n•	на початку аукціону оголошується найвища ціна на товар, а потім ставки знижуються до тієї, на яку погодиться перший покупець;\n•	це оптовий аукціон, на якому продавець може виставляти багато одиниць товару одночасно;\n•	в Україні регулюється законом «Про приватизацію невеликих державних підприємств».\nУ майбутньому кількість голландських аукціонів в Україні планується звести до мінімуму.\n\"', 2, '2015-06-09 06:40:20', 'post_image-29.jpeg', 47),
(12, 'Програма «орендного житла» 2015', 'У жовтні 2015 року Мінрегіон планує зареєструвати у парламенті законопроект щодо «орендного житла». У законопроекті передбачені особливі умов для інвесторів – відсутність плати на соціально-економічний розвиток та гарантії підключення об’єкта до електромереж.\nУ різних країнах під «орендним житлом» розуміють різний формат державних і приватно-державних програм. Найчастіше у світі «орендним» називають житло за яке орендар здійснює щомісячну сплату та значна частина цих грошей йде на викуп цього житла.\nНа даний момент найбільш імовірним інвестором житлової програми є Китай – з компанією з Піднебесної в березні поточного року був підписаний меморандум про виділення $15 млрд на доступне житло. Влада готова розглядати пропозиції і від інших інвесторів.\nВ Україні у житловій черзі перебувають понад 800 тисяч сімей. При нинішніх темпах забезпечення громадян житлом країні буде потрібно більше 100 років на вирішення квартирного питання.\nВ якості пілотних майданчиків для реалізації програми «орендного житла» розглядаються великі міста, зокрема, Харків.\n', 2, '2015-08-17 16:45:09', 'post_image-1.jpeg', 65),
(13, 'Екопоселення в Україні', 'Скільки точно екопоселень є в Україні − достеменно невідомо. \nУ 2011 році називалась цифра 25, але дані приблизні, оскільки держава не веде лік цим адмінодиницям, а люди, що вирішили виїхати за межі міст і вести натуральне господарювання, іноді не поспішають оголошувати про своє існування як одиниці соціуму.\nВсесвітня мережа екопоселень нараховує трохи більше 400 екопоселень у всьому світі, але українські громади не поспішають у ній реєструватись. Буває, що кілька родин-однодумців об’єднуються довкола ідеї екологічного буття і разом утворюють родове поселення або помістя.\nЯкщо люди, що обирають екопоселення без об’єднання у рід, керуються принципом дбайливого ставлення до природи й натуралізацією господарства, то родові помістя, цінуючи екопростір, консолідуються довкола безпосередньо роду й стосунків у ньому. Роди можуть об’єднуватись на основі сусідства.\nЖителі екосіл притримуються здорового способу життя, що передбачає загартовування, відвідування бань, парилок, саун, заняття різними видами спорту  та ін. На території екосіл не вітається куріння, вживання спиртних напоїв, нецензурна лексика, грубість у стосунках.\nІніціативу екопоселень в Україні можна назвати цілком логічною і корисною, з огляду на чималу кількість покинутих земель та сіл, що вимерли або ж знаходяться на межі вимирання.\n\"\"\"', 2, '2015-08-17 17:00:33', 'post_image-16.jpeg', 107),
(14, 'Будівельна амністія', 'До кінця 2015 року в Україні діятиме \"будівельна амністія\".\nЦе доступний і швидкий спосіб легалізувати самовільні будівництва, якщо будівельні роботи відбувалися в період з 5 серпня 1992 року по 12 березня 2011 року і не порушують державних будівельних норм щодо розміщення об\'єкта.\nЛегалізація самобудів у рамках \"будівельної амністії\" відбувається відповідно до закону України \"Про внесення змін до Закону України \"Про регулювання містобудівної діяльності\" щодо прийняття в експлуатацію об\'єктів будівництва, споруджених без дозволу на виконання будівельних робіт\" від 13 січня 2015 № 92 VIII та наказу Мінрегіону № 79 \"Про затвердження порядку прийняття в експлуатацію та проведення технічного обстеження індивідуальних (садибних) житлових будинків, садових, дачних будинків, господарських (присадибних) будівель і споруд, громадських будівель і будівель і споруд сільськогосподарського призначення I і II категорії складності, які побудовані без дозволу на виконання будівельних робіт\".\nТак, під \"будівельну амністію\" підпадають:\n•	індивідуальні (садибні) житлові будинки, садові, дачні будинки, господарські (присадибні) будівлі та споруди;\n•	громадські будівлі I і II категорій складності;\n•	будівлі та споруди сільськогосподарського призначення I і II категорій складності.\n\"Будівельна амністія\" не передбачає сплати штрафів.\n\"', 2, '2015-08-17 17:17:58', 'post_image-3.jpeg', 88),
(10, 'Новітні зміни Земельного законодавства України 2015 року', 'Прийнято 4 Закони\n\nЗакон України від 12 травня 2015 року № 388-VIII \"Про внесення змін до деяких законодавчих актів України щодо заборони приватизації обєктів інженерної інфраструктури меліоративних систем та земель державної і комунальної власності, на яких ці обєкти розташовані\" передбачає, що землі під обєктами інженерної інфраструктури меліоративних систем, які перебувають у державній і комунальній власності, не можуть передаватись у приватну власність.\n<a href=\"http://zakon4.rada.gov.ua/laws/show/388-19\" target=\"_blank\">Перейти на сайт Верховної ради</a>  \n\nЗакон України від 14 травня 2015 року № 418-VIII Про внесення змін до деяких законодавчих актів України щодо формування земельних ділянок та їх державної реєстрації на підставі документації із землеустрою, розробленої до 2013 року, спрямований на спрощення процедури оформлення права власності, права користування земельними ділянками для осіб, які до 2013 року розпочали процедуру отримання земельних ділянок у власність чи користування із земель державної та комунальної власності, але через законодавчі зміни не змогли завершити цю процедуру.\nЗаконом внесено зміни до Земельного кодексу України та Закону України Про Державний земельний кадастр, якими надано можливість здійснення державної реєстрації земельної ділянки на підставі технічної документації із землеустрою щодо складання документів, що посвідчують право на земельну ділянку, яка була розроблена на підставі рішення відповідного органу виконавчої влади чи органу місцевого самоврядування про надання або передачу земельної ділянки у власність або надання в користування, у тому числі на умовах оренди, до 1 січня 2013 року, але відомості про таку земельну ділянку не були внесені до Державного реєстру земель.\n<a href=\"http://zakon4.rada.gov.ua/laws/show/418-19\" target=\"_blank\">Перейти на сайт Верховної ради</a>  \n\nЗаконом України від 14 травня 2015 року № 417-VIII Про особливості здійснення права власності у багатоквартирному будинку внесено зміни до Земельного кодексу України, якими передбачено наступне.\nЗемельні ділянки, на яких розташовані багатоквартирні будинки, а також належні до них будівлі, споруди та прибудинкова територія, що перебувають у спільній сумісній власності власників квартир та нежитлових приміщень у будинку, передаються безоплатно у власність (спільну сумісну) або в постійне користування співвласникам багатоквартирного будинку.\nТаким чином, розширено коло субєктів, яким надано можливість набувати на праві постійного користування земельні ділянки із земель державної та комунальної власності, а саме до них віднесено співвласників багатоквартирного будинку для обслуговування такого будинку та забезпечення задоволення житлових, соціальних і побутових потреб власників (співвласників) та наймачів (орендарів) квартир та нежитлових приміщень, розташованих у багатоквартирному будинку.\nКрім того, передбачено додаткові гарантії прав на земельні ділянки для співвласників багатоквартирного будинку. Так, у разі знищення (руйнування) багатоквартирного будинку майнові права на земельну ділянку, на якій розташовано такий будинок, а також належні до нього будівлі, споруди та прибудинкова територія, зберігаються за співвласниками багатоквартирного будинку.\n<a href=\"http://zakon4.rada.gov.ua/laws/show/417-19\" target=\"_blank\">Перейти на сайт Верховної ради</a>  \n\nЗакон України від 2 червня 2015 року № 497-VIII Про внесення змін до деяких законодавчих актів України щодо визначення складу, змісту та порядку погодження документації із землеустрою.\nЗаконом внесено зміни до Земельного кодексу України, Законів України  Про землеустрій, Про порядок виділення в натурі (на місцевості) земельних ділянок власникам земельних часток (паїв),  Про охорону земель, Про державний контроль за використанням та охороною земель, Про державну експертизу землевпорядної документації, Про землі енергетики та правовий режим спеціальних зон енергетичних обєктів, Про правовий режим земель охоронних зон обєктів магістральних трубопроводів, Про Державний земельний кадастр, що спрямовані на закріплення єдиного переліку видів документації із землеустрою, визначення складу і змісту усіх видів документації із землеустрою, а також вичерпного переліку субєктів, які здійснюють погодження конкретних видів документації із землеустрою, усунення розбіжностей у назвах документації із землеустрою у різних законах.\n<a href=\"http://zakon2.rada.gov.ua/laws/show/497-19\" target=\"_blank\">Перейти на сайт Верховної ради</a>  \n\nВидано 1 наказ\n\nНаказ Міністерства регіонального розвитку, будівництва та житлово-комунального господарства України від 04.06.2015 № 125 Про затвердження форм документів із підготовки оцінювачів з експертної грошової оцінки земельних ділянок (зареєстровано в Міністерстві юстиції України 19 червня 2015 р. за № 734/27179), яким затверджено форми документів, які видаються при підготовці оцінювачів з експертної грошової оцінки земельних ділянок, а саме: Кваліфікаційного свідоцтва оцінювача з експертної грошової оцінки земельних ділянок; Посвідчення про підвищення кваліфікації оцінювача з експертної грошової оцінки земельних ділянок; Свідоцтва про проходження навчання за програмою базової підготовки з експертної грошової оцінки земельних ділянок.\n<a href=\"http://zakon4.rada.gov.ua/laws/show/z0734-15\" target=\"_blank\">Перейти на сайт Верховної ради</a>  \n\nНабрали чинності два Закони України та одна постанова Кабінету Міністрів України\n\n05.04.2015 – Закон України Про внесення змін до деяких законодавчих актів України щодо спрощення умов ведення бізнесу (дерегуляція) від 12 лютого 2015 року № 191-VIII, яким внесено зміни до Земельного кодексу України, Законів України Про оренду землі, Про землеустрій,   Про охорону земель, Про державну експертизу землевпорядної документації, спрямовані, зокрема, на скорочення дозвільних і погоджувальних процедур, стимулювання раціонального використання сільськогосподарських земель та спрощення орендних відносин.\n<a href=\"http://zakon2.rada.gov.ua/laws/show/191-19\" target=\"_blank\">Перейти на сайт Верховної ради</a>  \n\n28.06.2015 – Закон України від 2 березня 2015 р. № 222-VIII Про ліцензування видів господарської діяльності, спрямований на спрощення процедур ліцензування видів господарської діяльності та зменшення кількості видів господарської діяльності, що підлягає ліцензуванню.\nЗокрема, зазначений Закон не передбачає ліцензування господарської діяльності з проведення землеоціночних робіт та земельних торгів (на відміну від діючого раніше Закону України Про ліцензування певних видів господарської діяльності від 01.06.2000 № 1775-III).\nЗаконом внесено відповідні зміни до Земельного кодексу України, Законів України Про оцінку земель та Про Державний земельний кадастр.\n<a href=\"http://zakon2.rada.gov.ua/laws/show/222-19\" target=\"_blank\">Перейти на сайт Верховної ради</a>  \n\n20.05.2015 – Постанова Кабінету Міністрів України від 25 березня 2015 р. № 268 Про внесення змін до методик, затверджених постановами Кабінету Міністрів України від 23 березня 1995 р. № 213 і від 23 листопада 2011 р. № 1278, якою внесено зміни до Методики нормативної грошової оцінки земель сільськогосподарського призначення та населених пунктів і Методики нормативної грошової оцінки земель несільськогосподарського призначення (крім земель населених пунктів) та термін видачі територіальним органом Держгеокадастру витягу з технічної документації про нормативну грошову оцінку земель зменшено з семи до трьох робочих днів з дати надходження відповідної заяви.\n<a href=\"http://zakon4.rada.gov.ua/laws/show/268-2015-%D0%BF\" target=\"_blank\">Перейти на сайт Верховної ради</a> \"\"\"', 2, '2015-08-10 21:05:40', 'post_image-8.jpeg', 171),
(11, 'БЕЗОПЛАТНЕ ОТРИМАННЯ ЗЕМЕЛЬНИХ ДІЛЯНОК', 'Земельний кодекс України встановлює право кожного громадянина України на безоплатне одержання земельних ділянок по кожному виду використання (усього 5 видів). \nСтаття 121. Норми безоплатної передачі земельних ділянок громадянам\n1. Громадяни України мають право на безоплатну передачу їм земельних ділянок із земель державної або комунальної власності в таких розмірах:\nа) для ведення фермерського господарства – в розмірі земельної частки (паю), визначеної для членів сільськогосподарських підприємств, розташованих на території сільської, селищної, міської ради, де знаходиться фермерське господарство. Якщо на території сільської, селищної, міської ради розташовано декілька сільськогосподарських підприємств, розмір земельної частки (паю) визначається як середній по цих підприємствах. У разі відсутності сільськогосподарських підприємств на території відповідної ради розмір земельної частки (паю) визначається як середній по району;\nб) для ведення особистого селянського господарства – не більше 2,0 гектара;\nв) для ведення садівництва – не більше 0,12 гектара;\nг) для будівництва і обслуговування жилого будинку, господарських будівель і споруд (присадибна ділянка) у селах – не більше 0,25 гектара, в селищах – не більше 0,15 гектара, в містах – не більше 0,10 гектара;\nґ) для індивідуального дачного будівництва – не більше 0,10 гектара;\nд) для будівництва індивідуальних гаражів – не більше 0,01 гектара.\n2. Розмір земельних ділянок, що передаються безоплатно громадянину для ведення особистого селянського господарства, може бути збільшено у разі отримання в натурі (на місцевості) земельної частки (паю).\n3. Розмір земельної ділянки, що передається безоплатно громадянину у власність у зв\'язку з набуттям ним права власності на жилий будинок, не може бути меншим, ніж максимальний розмір земельної ділянки відповідного цільового призначення, встановлений частиною першою цієї статті (крім випадків, якщо розмір земельної ділянки, на якій розташований будинок, є меншим).\nДля отримання земельної ділянки, громадянину України необхідно звертатися до 5-ти уповноважених органів із заявами в такому порядку: \nЕТАП 1. Подати до уповноваженого органу заяву про безоплатне надання земельної ділянки.  Щодо земель комунальної власності, розташованих у межах населених пунктів, таким органом є сільська, селищна, міська рада. Щодо земель державної власності, розташованих за межами населених пунктів уповноваженим органом можуть бути дві різних установи, залежно від цільового призначення землі.\nЗемельними ділянками для ведення садівництва або особистого селянського господарства розпоряджається Головне управління Державного агентства земельних ресурсів області, у інших випадках – районна державна адміністрація.\nДо заяви додати: \n˗	викопіювання з кадастрової карти (плану) (його можна замовити у районному (міському) управлінні земельних ресурсів) або інші графічні матеріали, на яких слід зазначити бажане місце розташування земельної ділянки;\n˗	погодження землекористувача (у разі вилучення земельної ділянки, що перебуває у користуванні інших осіб) та документи, що підтверджують досвід роботи у сільському господарстві або наявність освіти, здобутої в аграрному навчальному закладі (у разі надання земельної ділянки для ведення фермерського господарства);\n˗	копію документу, що посвідчує особу (наприклад, паспорта громадянина України).\nЗа наслідками розгляду заяви, уповноважений орган має прийняти рішення про надання дозволу на розробку проекту землеустрою щодо відведення земельної ділянки або надати відмову.\nРішення про надання дозволу має бути прийняте у місячний строк. \nРішення про відмову у наданні дозволу має бути мотивоване.\nПідставами відмови відповідно до Статті 118 Земельного кодексу України можуть бути лише невідповідність місця розташування об\'єкта вимогам законів, прийнятих відповідно до них нормативно-правових актів, генеральних планів населених пунктів та іншої містобудівної документації, схем землеустрою і техніко-економічних обґрунтувань використання та охорони земель адміністративно-територіальних одиниць, проектів землеустрою щодо впорядкування територій населених пунктів. \nЕТАП 2. Укласти Типовий договір з землевпорядною організацією про вартість та строки виконання робіт. Форма такого договору затверджена Кабінетом Міністрів України знаходиться на Земельному порталі України zem.ua\nСтрок виконання робіт згідно законодавства не може перевищувати 6 місяців. Проект землеустрою має бути складений у паперовій формі (обов’язково)  та у формі електронного документу. У разі виникнення спору щодо меж земельної ділянки у суді, слугувати доказом може тільки паперова документація.\nЗемельний кодекс України встановлює обов’язковість погодження меж земельної ділянки із власниками та користувачами суміжних ділянок при проведенні кадастрових зйомок. Проте це не означає, що сусід може безпідставно відмовити у такому погодженні, вимагаючи перенесення межі на свою користь. Усі свої вимоги він має аргументувати і підтвердити документально. \nПроект землеустрою щодо відведення земельної ділянки підлягає погодженню уповноваженими органами влади відповідно до статті 186-1 Земельного кодексу України. У разі, якщо надання земельної ділянки планується здійснити за рахунок особливо цінних земель, земель лісогосподарського призначення, а також земель водного фонду, природоохоронного, оздоровчого, рекреаційного та історико-культурного призначення, проект землеустрою щодо відведення земельних ділянок підлягає обов’язковій експертизі, яка проводиться Держземагентством України. \nВиконавцем робіт у землевпорядній організації може бути лише особа, що має сертифікат інженера-землевпорядника. Перелік таких осіб розміщений на офіційному сайті Держземагентства за адресою: http://www.dazru.gov.ua (підрозділ «Державний реєстр сертифікованих інженерів-землевпорядників» розділу «Ліцензування та сертифікація»). \nЕТАП 3. Звернутися до державного кадастрового реєстратора у територіальному (районному, міському) органі Держземагентства України із заявою про державну реєстрацію земельної ділянки. Якщо інше не передбачено договором про розроблення проекту, до цього органу має звертатись землевпорядна організація. \nДержавний кадастровий реєстратор реєструє земельну ділянку у Державному земельному кадастрі протягом 14 днів і видає Витяг із Державного земельного кадастру про земельну ділянку із зазначенням у ньому кадастрового номеру.\nДо заяви додати: \n–	копію документа, що посвідчує особу; \n–	копію документа, що посвідчує повноваження діяти від Вашого імені (договір, довіреність); \n–	копію документа про присвоєння податкового номера; \n–	розроблений та погоджений уповноваженими органами проект землеустрою щодо відведення земельної ділянки у паперовому вигляді та у формі електронного документу, а у разі, якщо щодо проекту проводилась державна експертиза – також оригінал позитивного висновку цієї експертизи. \nЕТАП 4. Подати заяву про затвердження проекту землеустрою щодо відведення земельної ділянки до уповноваженого органу.\nДо заяви додати:\n–	примірник погодженого проекту, \n–	витяг із Державного земельного кадастру про земельну ділянку. \nРозглянувши заяву, уповноважений орган має прийняти рішення про затвердження проекту та звернутись до Реєстраційної служби відповідного підрозділу Міністерства юстиції України за місцезнаходженням земельної ділянки із заявою про державну реєстрацію права власності держави або територіальної громади на земельну ділянку. \nПісля здійснення державної реєстрації права власності держави чи територіальної громади на земельну ділянку, вказаний орган має прийняти рішення про безоплатну передачу земельної ділянки Вам у власність. У рішенні обов’язково має бути зазначена площа, місце розташування та кадастровий номер земельної ділянки, який зазначений у Витязі із Державного земельного кадастру. \nЕТАП 5. Подати заяву про державну реєстрацію права власності на земельну ділянку (до Реєстраційної служби, або через державного кадастрового реєстратора управління земельних ресурсів, у якому отримували Витяг із Державного земельного кадастру. Бланк заяви можна завантажити з офіційного сайту Державної реєстраційної служби за адресою: http://www.drsu.gov.ua/show/10163.\nПісля розгляду заяви протягом 14 днів видається Свідоцтво про право власності на земельну ділянку та Витяг із Державного реєстру речових прав на нерухоме майно та їх обтяжень.\nДо заяви додати:\n–	копію документа, що посвідчує особу заявника; \n–	копію реєстраційного номера облікової картки платника податку згідно з Державним реєстром фізичних осіб-платників податків; \n–	документ, що підтверджує внесення плати за надання витягу з Державного реєстру прав;\n–	документ про сплату державного мита (крім випадків, коли особа звільнена від сплати державного мита);\n–	засвідчену копію рішення про безоплатну передачу земельної ділянки, \n–	витяг із Державного земельного кадастру про земельну ділянку.\"', 2, '2015-08-11 18:55:48', 'post_image-11.jpeg', 26),
(17, 'Тенденції ринку нерухомості 2015', 'Фахівці британського аналітичного агентства оцінили тенденції ринку нерухомості 2015 року.\nЕксперти стверджують, що житло в Україні за минулий рік подешевшало в середньому на 30%.\nЗа останній рік українці купили більше нерухомості за кордоном на 30%, порівняно з попереднім роком. У більшості випадків українці переїжджають у Туреччину, Болгарію або Іспанію.\nБільшість українців можуть дозволити собі недороге житло вартістю від 80 до 150 тисяч доларів. Наприклад, квартиру в Туреччині можна придбати за 900 доларів за квадратний метр, а за 80 тисяч доларів продаються апартаменти з однією спальнею, але зате на першій лінії морського берега. У Болгарії можна купити однокімнатну квартиру площею 54 квадратних метри недалеко від моря за 23 тисячі євро.\nЦіни впали на нерухомість: у Росії – на 6%; у Греції та Словенії – на 4%; на Кіпрі, у Латвії та Італії – на 3%; в Іспанії, Фінляндії, Румунії – на 2%; в Португалії – на 0,5%.\nНерухомість піднялася в ціні: в Ірландії та Естонії – на 16,5%; у Швеції – на 8,8%; у Туреччині на 8%. У середньому ж по країнах Євросоюзу підвищення відбулося на 2,6%.\nНерухомість Ізраїлю, Чорногорії та Каліфорнії стрімко зростає в ціні.\nУ другому кварталі 2015 ціни на ізраїльське житло зросли на 2,7% в квартальному і на 5% в річному численні. Таке різке пожвавлення на ринку було спровоковане ініціативою Міністра фінансів країни Моше Кахлона. На початку червня чиновник оприлюднив нову житлову програму, яка, крім усього іншого, має на увазі збільшення податку на покупку «вторинного» житла з 5-8% до 8-10%. За рахунок цього уряд планує знизити попит, а відповідно і ціни на житлову нерухомість, що зробить її більш доступною.\nУ другому кварталі 2015 середня вартість новобудов у Чорногорії склала € 1160 за кв.м. Це на 8,1% вище, ніж кварталом раніше, і на 1,9% більше в порівнянні з попереднім роком.\nЖитло в Каліфорнії стає все менш доступним. Різко зростаючий попит на нерухомість Каліфорнії прискорив ціни, які досягли рівня 2007 року.\n', 2, '2015-08-18 19:04:47', 'post_image-14.jpeg', 75),
(18, 'ТОП-10 міст, де зростають ціни на елітну нерухомість', 'У другому кварталі 2015 ціни на елітну нерухомість у світі збільшилися на 2,5%. Але кылькысть міст, що показали значне зростання вартості таких об\'єктів, скоротилася. Якщо роком раніше вісім мегаполісів демонстрували зростання у двозначних цифрах, то у другому кварталі 2015-го їхня кількість зменшилася до чотирьох, повідомляється в звіті Prime Global Cities Index від компанії Knight Frank.\nВанкувер, Майамі і Сідней стали лідерами за відповідними показниками. Цьому сприяли низькі процентні ставки, зростаюча економіка і приплив капіталу.\nАзіатські міста зміцнюють свої позиції. Сім із десяти у рейтингу міст розташовані саме в Азіатсько-Тихоокеанському регіоні.\nСеред європейських міст переможцем став Монако, де ціни на елітне житло за рік зросли на 7,9%.\nТОП-10 міст з найзначнішим річним зростанням цін на елітну нерухомість:\n1. Ванкувер – 15%\n2. Майамі – 13,9%\n3. Сідней – 12,5%\n4. Бангалор – 10,3%\n5. Токіо – 9,8%\n6. Джакарта – 9,4%\n7. Мельбурн – 7,9%\n8. Монако – 7,9%\n9. Сеул – 7,6%\n10. Шанхай – 7,3%\n\"\"', 2, '2015-08-18 21:04:55', 'post_image-23.jpeg', 94),
(19, 'Розпродаж островів Греції', 'Експерти з компанії Knight Frank прогнозують: грецька влада, щоб поповнити скарбницю, виставить на продаж острови. Нове податкове законодавство в Греції зробило багато островів занадто дорогими для їх утримання. Тільки в 2014 році на продаж у зв\'язку з цим було виставлено 20 ділянок суші. Лише 10% островів на сьогоднішній день є приватними, а всього в державній власності є від 1200 до 6000 дрібних і великих островів.\nНаразі на продаж виставлено острів Гайя в Іонічному морі вартістю $4,7 млн. Відомо, що купівлею цієї ділянки суші зацікавилися Бред Пітт і Анджеліна Джолі.\nЗа €3,4 млн можна придбати півострів Ліхнарі, в регіоні Коринфа. \"Фішка\" цього об\'єкта – оливковий гай з 650 деревами і джерела прісної води. До речі, ціна на острів була знижена вдвічі.\nОстрів Кардіотісса, в самому серці Егейського моря, коштує дорожче – €7,4 млн. Можливості розвитку не обмежені зведенням власного будинку, він підходить для будівництва курорту. Тут діє сервіс для вітрильного спорту, дайвінгу та екстремальних видів спорту.\nІнвесторів зацікавить і Като Антікері в Егейському морі, розташований у декількох хвилинах від пам\'яток острова Аморгос. Ділянка продається разом із дозволом на будівництво, і може бути використана в комерційних або особистих цілях. Зараз на Като Антікері є дві гавані, два старих будинки і церква. На острові проведено електрику, система переробки сонячної енергії та телефонний зв\'язок. Ціна лота повідомляється тільки за запитом.\nВлітку 2015-го вже були укладені вигідні зіркові угоди.\nГоллівудський актор Джонні Депп, у середині липня 2015 витратив €4 млн на покупку острова Строггіно в Егейському морі. Про цю ділянку суші відомо, що там є  110-метровий пляж, який можна легко обладнати під курорт.\nУ цей же час острів Агіос Томас в Саронічній затоці Егейського моря став власністю мільярдера Уоррена Баффета. Найбільший у світі інвестор вирішив не відставати від кінозірок і вклав разом з італійським партнером Алессандро Прото €15 млн у цей невеликий шматочок щедрою грецької землі. Як справжній бізнесмен, Баффет вирішив не розмінюватися на дрібниці та інвестувати тут у будівництво нерухомості.\nІ нарешті, новому тренду піддався лідер мадридського «Реалу» Кріштіану Роналду. Зірковий футболіст був запрошений на весілля до свого агента Жорже Мендеш як боярин. У якості подарунка він приготував грецький острів. Як повідомляють ЗМІ, вартість цього царського презенту становить від €3 до €50 млн.\n', 2, '2015-08-18 21:37:58', 'post_image-18.jpeg', 24),
(20, 'Новобудови Німеччини', 'У Німеччині переважають квартири середньої та великої площі. У деяких містах 95% усіх угод з нерухомості проводяться за допомогою іпотеки. Пайовик не вносить передплату за незавершене будівництво.\nЗа даними статистики, середня площа квартири німецької новобудови становить 91 кв.м. Тенденції до переважання невеликих квартир не спостерігається. У Мюнхені, наприклад, частка таких об\'єктів не перевищує 20%. Однак попит на маленькі квартири залишається стабільно високим, у тому числі через те, що нового житла в цьому сегменті з\'являється небагато.\nНімці – не аматори безлічі сусідів в будинку. Адже інакше максимальний порядок і чистоту всередині будівлі підтримувати проблематично. Крім того, тут прийнято зберігати архітектурний вигляд міст. Тому кількість поверхів у новобудовах зазвичай не перевищує чотирьох-шести.\nУ багатоквартирних будинках економ-класу здача квартир «під ключ» не практикується. Інша справа – нерухомість преміум-класу, яка часто будується з урахуванням бажань покупця.\nКільцеві дороги навколо міст у Німеччині зустрічаються нечасто. Громадяни, завдяки розвиненій інфраструктурі, часто можуть жити і зовсім поруч із центром міста. Тому іноді нові будинки з\'являються на місці знесених старих будов або просто при наявності вільної землі. Правда, не скрізь: наприклад, у Мюнхені, навпаки, дефіцит і дорожнеча земельних ділянок змушують вести масову забудову на околиці або за межею міста.\nКрім безпосередньо під\'їздів і доріжок забудовник лише іноді передбачає в проекті підземний гараж. В іншому зазвичай немає необхідності. Адже в безпосередній близькості до центру забудови як правило є і садки, і дитячі майданчики.\nУ деяких містах Німеччини підземний паркінг з обов\'язковим місцем під кожну квартиру, норми по тепло- і шумоізоляції будівлі, повністю закінчена територія комплексу є обов\'язковими при отриманні дозволу на будівництво багатоквартирного будинку. А ось такі опції, як басейн або консьєрж-сервіс не є обов\'язковими, оскільки істотно збільшують експлуатацію будівлі і, як наслідок, розмір комунальних платежів.\nВ окремих населених пунктах майже 95% угод проводиться за допомогою іпотеки. Цьому сприяють, насамперед, низька процентна ставка (2,5-4%) і більш надійна економічна ситуація, яка дає людям упевненість у завтрашньому дні і в довгостроковому збереженні свого доходу. Банк зазвичай фінансує 40-50% від вартості нерухомості.\nЗростання цін на нерухомість у процесі будівництва виключене, оскільки всі параметри і суми заздалегідь обумовлюються в двосторонньому договорі, а інфляція не настільки істотна, щоб тільки за рахунок неї відчутно скоротити заздалегідь запланований прибуток компанії-забудовника.\nПрава пайовиків захищаються налагодженою судово-правовою системою. Усе прописується у договорах. Найголовніше – забудовник не має права брати передплату за будівництво об\'єкта. Рахунки на оплату виставляються виключно за виконані обсяги робіт.\nНайбільша потенційно можлива небезпека для покупця – розорення будівельної фірми до закінчення будівництва, коли квартира ще не готова для проживання, а покупець уже вніс більшу частину грошей. Такі ситуації дійсно зустрічаються на місцевому ринку нерухомості, але рідко. Найчастіше таке відбувається з дрібними компаніями, що будують не багатоквартирні, а приватні будинки. І враховуючи, що на ринку є різні програми страхування, імовірність повної втрати грошей у такій ситуації зводиться до нуля.\n', 2, '2015-08-18 21:57:06', 'post_image-19.jpeg', 15),
(21, 'Новобудови Болгарії', 'На курортах Болгарії немає бетонних гігантів. Кількість поверхів у будинку не перевищує семи. Оздоблення та меблі додаються. У Софії інвестиції в новобудови вигідніші, ніж на курорті.\n60-70% всіх об\'єктів у новобудовах на курортах Болгарії – це студії або квартири з однією спальнею, 25% – квартири з двома спальнями, і лише близько 5% – квартири з трьома спальнями. Покупці курортного житла в Болгарії в основному купують об\'єкти в новобудовах в якості альтернативи номеру в готелі. Тому їм не потрібні великі апартаменти.\nЗараз 90% усіх квартир з однією спальнею в новобудовах Болгарії – «євродвушки», де вітальня об\'єднана з кухнею. Причому вони популярні не тільки у зарубіжних покупців нерухомості, але й у місцевих жителів, які встигли оцінити переваги таких об\'єктів.\nУ курортних зонах кількість поверхів у новобудовах не перевищує семи. У великих містах зустрічаються будівлі висотою до 10 поверхів, але не більше, оскільки болгари не люблять жити у висотках. Будівлі з кількістю поверхів до 30 можна зустріти в Софії, однак усе це – старі будівлі із соціалістичної епохи.\nСитуація на ринку житла у великих містах і на курортах різниться. У Софії, наприклад, існує державний стандарт обробки квартир у новобудовах. Він припускає штукатурення стіни і наявність електричних кабелів. Однак у введених в експлуатацію квартирах немає ні міжкімнатних дверей, ні побілки стін, ні підлогових покриттів. Квартири «під ключ», з меблями і технікою можна купити лише на вторинному ринку.\nНа курортах усе інакше. Більшість покупців віддають перевагу апартаментам з побілкою стін, покриттям для підлоги та кахлем у ванній кімнаті.\n У курортних зонах новобудови часто зводяться в безпосередній близькості до пляжу. У великих містах, наприклад, у Софії, зустрічаються новобудови як у спальних районах, так і в центрі міста. На околицях часто будуються офісні центри, і там є станції метро, тому багатьом зручно жити неподалік від роботи.\nЗабудовник спільно з муніципалітетами створює мінімальну інфраструктуру, наприклад, дороги, маленький садок у дворі. У великих містах Болгарії існує ще обов\'язкова вимога по наявності місць на підземній парковці для автомобілів. Для курортної нерухомості характерна обов\'язкова наявність басейну. А для квартир, розташованих на гірськолижних курортах, часто обов\'язковою вимогою є обладнання ресепшн-зони.\nЗ 2009 по 2011 роки процентні ставки на іпотечні кредити становили 10-13%. У цей період люди воліли не брати кредити на купівлю житла через високі ставок. Зараз же вони складають близько 6%, і населення починає все більше користуватися позиками на придбання нерухомості. Частка угод з іпотекою становить близько 50%, і вона постійно зростає. При цьому банк фінансує 80-85% від вартості квартири.\nДо останнього часу ціни на житло в Софії знижувалися. З 2008 року спад склав близько 30%. Зараз же намітилося стабільне зростання вартості квартир у новобудовах. У міру зведення будівлі вартість квартир виростає на 10-20%. Тому в Болгарії також вигідно купувати житло на стадії котловану, звичайно, у надійного забудовника. Те ж саме стосується курортної нерухомості.\nКоли ви купуєте житло в новобудові на стадії котловану, ви укладаєте попередній договір із забудовником. У ньому прописані терміни здачі об\'єкта в експлуатацію. Компанію можуть оштрафувати за їх невиконання або прострочення. Також покупцеві рекомендується перевірити фінансові документи забудовника, дозвіл на будівництво та інші супутні документи.\nТим не менш, іноді трапляються затримки введення будинків в експлуатацію, найчастіше вони можуть бути пов\'язані з фінансовими проблемами забудовника або з причинами, від забудовника не залежними.\n', 2, '2015-08-18 22:11:19', 'post_image-20.jpeg', 32),
(22, 'Лондон: популярні будинки-човни', 'У східній частині столичного боро Хакни, який стає все більш привабливим для творчої молоді та студентів, за останній рік число будинків-човнів зросло на 85%. Багато представників молоді, для яких орендувати житло занадто дорого, не кажучи вже про його придбання, вважають «плавучі будинки» розумним виходом із ситуації. Купивши човен, його можна на два тижні пришвартувати в будь-якому дозволеному місці Лондона і жити там без додаткових витрат.\nОднак такий спосіб життя підійде далеко не кожному і не повинен розглядатися як альтернативне рішення проблеми доступного житла. Життя в лондонському каналі на власному човні не позбавлене проблем і додаткових витрат. Кількість човнів швидко збільшується, попит на причали перевищує пропозицію, і в результаті витрати сильно зростають.\nТі ж, хто не може знайти й оплатити собі постійний причал, отримують спеціальну ліцензію. Вона дозволяє їм жити в каналі, але тільки за умови, що вони постійно будуть в «круїзі». Це означає, що човен не повинен бути пришвартований в одному місці більше 14 днів. Якщо умова буде порушена, «човняр» ризикує отримати обмеження або навіть анулювання човнової ліцензії.\nКрім того, є й побутові складності. Електрики ледь вистачає на загальні потреби, а основні санітарні завдання, такі як злив відходів у каналізацію, вимагають спеціалізованих заходів на березі річки. Тому умови життя далеко не завжди можна назвати комфортними.\n', 2, '2015-08-19 09:57:52', 'post_image-24.jpeg', 39),
(23, 'Туреччина збудує високотехнологічне екопоселення', 'Об\'єкт буде збудований уже у 2016 році. \nЖурі Міжнародного архітектурного фестивалю включило його в шорт-лист премії «Кращий комплекс майбутнього». Нове поселення розкинеться недалеко від найбільшої туристичної зони в Антальї.\nАрхітектором виступає турецьке бюро GAD Architecture, яке має досвід виконання проектів по всьому світу. Селище під назвою «АХК Кунду» розкинеться в 20 км на північ від Анталії неподалік від Середземного моря. Заплановано зведення 123 будинків різного розміру.\nБудинки будуть двоповерховими. Вони будуть з\'єднуватися між собою пішохідними доріжками та парками, які плавно переростатимуть у зону відпочинку на узбережжі. Там передбачені бігові доріжки, тенісні корти, футбольні майданчики і човнові станції.\nЕлектропостачання будинків здійснюватиметься за рахунок фотогальванічних сонячних панелей. Під час будівництва будуть використані тільки природні місцеві матеріали – камінь і деревина. Екопоселення буде повністю самодостатнім щодо ресурсів, транспорту та енергії завдяки використанню новітніх екологічних технологій.\nПоки на подібний проект замахнулися тільки в Дубаї. «Розумне місто» вмістить себе 160 тис. людей і розташується на території в 5665 гектарів.\n\"\"', 2, '2015-08-19 10:46:37', 'post_image-25.jpeg', 27),
(24, 'Китай стає світовим лідером 3D-будівництва', 'Компанія Zhuoda, яка займається зведенням об\'єктів за 3D-технологією, знизила витрати на будівництво до $ 400 за кв.м.\n«Звичайну віллу необхідно будувати як мінімум півроку, але з нашою 3D-технологією виробництво займає десять днів», – розповідає Ан Йонгліанг, інженер компанії Zhuoda, як повідомляє портал Property Report.\nВілла складається з шести надрукованих на 3D-принтері модулів, кожен із яких був створений окремо та згодом об\'єднаний із рештою за допомогою будівельного крана. Вага кожного модуля становить понад 100 кг, а вся вілла здатна витримувати навіть землетрус величиною 9 балів.\nСекрет успіху компанії лежить у використанні особливого матеріалу, який робить віллу вогнетривкою, водонепроникною, вільною від формальдегіду, аміаку та радону.\nУ січні 2015 інша компанія звела відразу кілька житлових будинків таким же способом. Новинкою навіть зацікавилася влада Єгипту.\n', 2, '2015-08-19 13:19:43', 'post_image-30.jpeg', 20),
(25, 'Огляд ринку нерухомості Німеччини 2015-2016', 'Євростат підрахував, що за підсумками 2014-го го нерухомість у Німеччині додала в ціні 2,4% за рік. \nЗа прогнозами агентства Standard & Poors, у 2015 році приріст цін на житло в Німеччині складе 5%, у 2016-му «квадрат» додасть ще 4,5%. Поки ніщо не говорить про те, що тренд на повільне, але впевнене подорожчання зміниться. Аналітики вважають, що німецький ринок усе ще недооцінений, а значить рости є куди.\nНайгучніший приклад – Берлін. П\'ять років тому ріелтори активно пропонували «одинички» в спальних районах за € 30 000, сьогодні вільну від орендаря квартиру в столиці дешевше ніж за € 50 000 не знайти. Винятки можливі, але зустрічаються вкрай рідко.\nЩе один приклад – Лейпциг. Населення міста зростає на 10 000 осіб на рік. Колосальний попит робить свою справу: за п\'ять років ціни на нерухомість в Лейпцигу подвоїлися. Екстремально дешевих пропозицій за € 10-15 тисяч тут більше немає, ціни стартують від € 25 000 – за квартиру на околицях.\nЗ погляду цін на нерухомість німецький ринок неоднорідний. Вартість квадрата варіюється від € 300 у маленьких містах до € 10 000 у центрі Мюнхена.\nНімеччина залишається «країною орендарів» – кожен другий німець живе в орендованій квартирі. Багато об\'єктів нерухомості продаються з укладеними договорами найму, при цьому зазвичай вони коштують на 15-30% дешевше вільних апартаментів.\nСередня прибутковість від оренди квартири у великих містах складає 2,5-3,5% річних, при цьому існує перспектива приросту капіталу за рахунок подорожчання квадратного метра. У провінції на оренді можна заробити до 10% річних, але при перепродажі житла через 5-10 років вартість об\'єкта, найімовірніше, не зміниться.\nКвартира на вторинному ринку в маленьких містах Німеччини, наприклад, в Плауені – від € 300-500 за кв.м\nКвартира в Лейпцигу, вторинний ринок, стан – житлова – від € 800 за кв.м – на околицях; від € 1000 за кв.м – у центрі.\nКвартира в Берліні, вторинний ринок, середній клас – від € 1800 за кв.м – у спальних районах; від € 2700 за кв.м – у центрі.\nБудинок площею 130-150 кв.м, із земельною ділянкою 1000 кв.м, на відстані 10 км. від Берліна – від € 300 000.\nАпартаменти в Ганновері, Дрездені, Штутгарті, вторинний ринок, середній клас – € 1200-2500 за кв.м. у залежності від стану будівлі, статусу квартири (здана в оренду чи ні), розташування і т.д.\nАпартаменти в Дюссельдорфі, Франкфурті, Гамбурзі, вторинний ринок, середній клас – € 500 2500-4 за кв.м, залежно від стану будівлі, статусу квартири (здана в оренду чи ні), розташування і т.д.\nКвартира в Мюнхені, вторинний ринок – від € 4000 за кв.м – у передмістях; від € 5000 за кв.м – у місті; до € 10 000 за кв.м – у центрі.\nУ Німеччині є тисячі провінційних містечок і селищ, де вартість квартир не змінюється десятиліттями. І при цьому є «гарячі точки», ситуація на ринку нерухомості яких вибивається із загальної картини.\n', 2, '2015-08-19 13:40:06', 'post_image-31.jpeg', 65),
(26, 'Огляд ринку нерухомості Греції 2015-2016', 'Найбільш популярний тип нерухомості на ринку Греції – курортні апартаменти і вілли. Дорогі або дешеві, у великих комплексах або маленьких, поблизу води або на пагорбах. Пропозицій вистачає. Навіть у проектах, збудованих ще за часів буму на ринку, продані не всі квартири.\nЗараз у центрі Афін можна купити квартиру за € 400 за квадратний метр. Якщо хороша вілла, у якій метрів 450 житлової площі, з власним басейном, знаходиться на пагорбі, на відстані двох-трьох кілометрів від пляжу – вона буде коштувати € 1,5-1,7 млн. Якщо ж вона на відстані 50 метрів від моря, ціна підвищиться до € 2,5-2,7 млн.\nКупуючи нерухомість у Греції не можна керуватися сухим розрахунком – вигідно-невигідно. Якщо щось і купувати, то тільки по любові: якщо місце подобається, якщо хочеться проводити тут не менше кількох місяців на рік, якщо сім\'я задоволена. Полюбити Грецію неважко. Є за що! Сонце, море, чудові продукти, сам ритм життя – неметушливий, розмірений. Європейська та православна країна, де люди живуть у спокої і, як мені здалося, особливо відкрито дивляться в очі.\nЗ приводу інтересу до Греції красномовно говорять цифри. У 2008 році Грецію відвідали 17 мільйонів туристів. А в 2014-му – 21 мільйон!\nІнтерес до грецької нерухомості сьогодні – у першу чергу з боку іноземних покупців. Місцеві жителі якраз у розгубленості: не дуже зрозуміло, за якими цінами продавати. Неясно, що вигідно – що невигідно.\nГреція – це море, сонце, повітря. Дивно, але самі греки вже забули про ці переваги. А іноземці пам\'ятають, і звертають увагу, і приймають рішення.\nКризу можна відчути насамперед у мегаполісах. А є місця, які через нього взагалі не постраждали. Наприклад, там, де активний туристичний ринок.\nКоли навколо ажіотаж, завжди є дивовижні можливості. Підвищується рентабельність, адже ціни впали, і значно – до 70%. І вони унікальні! Також як унікальні пропоновані умови; як унікальні місця, де можна купити нерухомість ...\nГреки, які продають будинки і квартири, не залишаються на вулиці. Вони просто почали позбавлятися від зайвого, а накопичено було дуже багато. В основному, за останні 20 років. Раніше було так: одна сім\'я, одна квартира, одна земельна ділянка. Після 2000 х – одна сім\'я, п\'ять квартир, п\'ять земельних ділянок.\nГреки звикли вкладати в нерухомість. Так було завжди. Можна сказати, це бажання на національному рівні. У греків не прийнято вкладатися у розкішні машини чи акції. Зате навіть у Лондоні серед основних інвесторів у нерухомість – заможні греки.\nЯкщо задуматися, на міжнародному ринку грецька нерухомість реально стала доступною у 2011 році, коли змінилося багато місцевих законів. А світова криза почалася у 2008-му, і почалася вона якраз із кризи нерухомості. Зараз перед грецьким ринком нерухомості відкрилися колосальні можливості.\nУ якийсь момент у багатьох країнах почали будувати дуже агресивно. На Кіпрі з\'явилися хмарочоси, в Іспанії – теж. На щастя, в Греції висотний коефіцієнт не дозволяє так будувати: сім з половиною метрів вгору – і все!\nСамим недооціненим регіоном Греції сьогодні є Афіни та Афінська Рів\'єра. Зараз всі знають Акрополь, але ж є Аттика, є Пелопоннес – і там дуже багато можливостей і для туризму, і для життя.\nПодивіться: навіть узимку в континентальній Греції, у районі Афін +15-17 градусів. Це відмінне місце для людей «третього віку», європейців і неєвропейців, що переміщуються у південні країни. І зараз, все більше і більше людей це розуміють.\nУ найближчі п\'ять років ринок нерухомості Греції чекають колосальні зміни. В останні два роки у пошуках земельних ділянок активізувалися величезні компанії. Цілі острова купують. І через 3-4 роки на цих островах, де нічого немає, збудують нове і сучасне житло, причому не обов\'язково дороге.\nСкоро в Греції з\'являться об\'єкти «широкого профілю» – призначені і для постійного проживання, і для туристичного бізнесу. Це навіть не апарт-готелі, а скоріше сучасні міні-містечка. З усім необхідним – медициною, освітніми установами, духовною культурою. Держава зобов\'язує створювати потужну інфраструктуру. Це і є сучасний рівень.\n', 2, '2015-08-19 14:18:24', 'post_image-32.jpeg', 61),
(27, 'Огляд ринку нерухомості ОАЕ 2015 – 2016', 'В Об\'єднаних Арабських Еміратах люблять ставити рекорди і вражати світову громадськість. Якщо вже ціни на нерухомість ростуть – то найшвидше у світі, а якщо падають – то так само нищівно. Утім, 2015 рік, судячи з усього, є винятком ...\nЗ 2006 по 2008 роки ціни на нерухомість в ОАЕ стрімко зростали. Стрімко – це означає на 20%, 30%, 50% на рік залежно від комплексу та типу нерухомості. Наступні кілька років, аж до 2011-го, падали з тією ж карколомною швидкістю. У 2012-му почався новий виток – Дубай став самим швидкозростаючим ринком у світі і до 2014-го ціни на житло перевищили докризовий рівень.\nУтім, до осені 2014-го крива вартості квадратного метра почала поступово випрямлятися і в 2015-му пішла на зниження. На відміну від попередніх спадів цей виявився напрочуд плавним. За даними консалтингової компанії Jones Lang LaSalle, у червні 2015-го квартири в Дубаї коштували в середньому на 9%, а вілли на 5% менше, ніж роком раніше. Причому одні комплекси впали в ціні більше, інші – менше, треті – навпаки, здорожчали.\nНад стабілізацією ситуації в галузі чимало потрудилася влада ОАЕ – приймала постанови, що підвищують прозорість ринку, і прагнула стримати спекуляції. Наприклад, у 2014 році вступив у силу закон, що підвищує реєстраційний збір на покупку нерухомості з 2% до 4%.\nУ 2015-му знижуються не тільки ціни, а й кількість угод. Однак дубайські девелопери не поспішають «заморожувати» будівництва і заявляють про все нові і нові мега-проекти, які з\'являться в еміраті до Всесвітньої виставки «Експо – 2020». Список з 15 найбільш амбітних ініціатив із загальним бюджетом в $ 66890000000 включає розширення міжнародного аеропорту Аль-Мактум, торгово-розважальний комплекс Mall Of The World, нафтопереробний завод Дубая, а також дві нові лінії метро.\n За інформацією Земельного департаменту, за перше півріччя 2015-го нерухомість в Дубаї придбали 19 848 інвесторів з 142 країн світу. Обсяг угод перевищив $ 14 млрд.\n Житло економ-класу в районах Дубая Jumeirah Village Circle, Sports City, Motor city, Al Furjan:\n˗ студії – від $ 150 000;\n˗ квартири з 1 спальнею – від $ 200 000;\n˗ таунхаус з 2 спальнями, 200 кв.м – від $ 450 000;\n˗ вілли з 2 спальнями, з земельною ділянкою, критої паркуванням, 260 кв.м – 630 000 $ від.\nНерухомість бізнес-класу в районах Dubai Marina, Jumeirah Beach Residence, Palm Jumeirah:\n˗ студії – від $ 200 000;\n˗ апартаменти з 1 спальнею – від $ 270 000. \nЕлітна нерухомість в районах Dubai Marina, Jumeirah Beach Residence, Palm Jumeirah:\n˗ студії – від $ 330 000;\n˗ квартири з 1 спальнею – від $ 390 000;\n˗ вілли тільки на «Пальмі», мінімум 4 спальні, 500 кв.м, – від $ 3 000 000.\nКоли ринок нерухомості ОАЕ почав охолоджуватися, його професійні учасники зітхнули з полегшенням. Найімовірніше, до початку 2016 продовжиться корекція – кількість угод, обсяг транзакцій, вартість квадратного метра продовжать знижуватися. За рік «квадрат» може втратити 5-10% залежно від локації і конкретного комплексу.\nВтім, спад не повинен виявитися затяжним. Не за горами «Експо-2020». Нові станції метро, новий аеропорт, нові комерційні і житлові комплекси будуть створені спеціально до цієї грандіозної виставки, яку повинні відвідати 20 мільйонів гостей. Очікується, що за пару років до знакової події ціни на житло знову почнуть рости, але вже не так швидко, як раніше – на 6-8% на рік. А от що буде після «Експо-2020», чи зможе ринок переварити створені під виставку об\'єкти, сьогодні не знає ніхто ...\n', 2, '2015-08-19 16:11:58', 'post_image-33.jpeg', 37);
INSERT INTO `posts` (`id`, `title`, `content`, `author_id`, `date`, `image`, `views`) VALUES
(28, 'Огляд ринку нерухомості Лондона', 'Лондон, площею близько 1580 кв.км, можна умовно розділити на кілька різних секторів ринку нерухомості в залежності від рівня цін на житло й оренду, привабливості району та інших критеріїв.\n1. Престиж. Райони Кенсінгтон (Kensington) і Челсі (Chelsea), незважаючи на те, що займають близько 1% площі Лондона, є найпрестижнішими і дорогими.\nСередня ціна будинку – 1,3 мільйона фунтів стерлінгів.\nСередня орендна плата – £ 3433 на місяць.\nЗростання цін на нерухомість у найближчі п\'ять років – 4,5% на рік.\n2. Недороге житло. У Баркінгу (Barking) і Дагінхеме (Dagenham) найнижчі ціни серед 33 районів Лондона. Саме ці 2 райони є фаворитами для тих, хто купує житло вперше.\nСередня ціна будинку – £ 270 256.\nСередня орендна плата – £ 1063 на місяць.\nЗростання цін на нерухомість у найближчі п\'ять років – 5,5% на рік.\n3. Спокійне життя. Зелений район Річмонд-апон-Темс (Richmond-upon-Thames) – один з престижних лондонських боро з низьким рівнем злочинності.\nСередня ціна будинку – £ 630 489.\nСередня орендна плата – £ 1755 на місяць.\nЗростання цін на нерухомість у найближчі п\'ять років – 6% на рік.\n4. Для молодих і сучасних. У 2014 році багато молодих фахівців знімали житло в Тауер-Хамлетс (Tower Hamlets). Цьому сприяло хороше співвідношення вартості оренди та близького розташування до Сіті і до Кенері Уорф (Canary Wharf). Офіси, банки, магазини, ресторани і бари різної цінової категорії дозволяють тут працювати, жити і розважатися не виходячи за межі свого району.\nСередня ціна будинку – £ 479 971.\nСередня орендна плата – £ 2160 на місяць.\nЗростання цін на нерухомість у найближчі п\'ять років – 6% на рік.\n5. Найдешевша орендна плата. Бекслі (Bexley) – одне з найбільш доступних місць для житла у Великому Лондоні. Згідно з даними аналітиків CBRE середня ціна за оренду квартири з двома спальнями становить £ 919 на місяць. Це одна з найзеленіших частин столиці з більш ніж 100 парками.\nСередня ціна будинку – £ 281 341.\nСередня орендна плата – £ 919 на місяць.\nЗростання цін на нерухомість у найближчі п\'ять років – 5% на рік.\n6. Жвавий п\'ятачок. Іслінгтон (Islington) є найщільнішим районом столиці. Якщо в середньому в Лондоні щільність населення становить 52 особи на 1 гектар, то в Іслінгтоні – на цій же площі вміщаються 139 людини. Цей район дуже подобається ІТ-фахівцям через його близьке розташування до Tech City (Silicon Roundabout, Кремнієве кільце).\nСередня ціна будинку – £ 662 198.\nСередня орендна плата – £ 2099 на місяць.\nЗростання цін на нерухомість у найближчі п\'ять років – 4% на рік.\n7. Правильний вибір для домовласників. У даний час Кройдон (Кройдон) – один із найкращих районів столиці для покупки нерухомості з метою здачі в оренду. У 2014 році ціна на оренду житла значно зросла. Ріелтори вважають, що незважаючи на те, що Кройдон знаходиться всього в 20 хвилинах їзди від центру столиці, його цінність недооцінена через історично погану репутацію.\nСередня ціна будинку – £ 320 123.\nСередня орендна плата – £ 1,253 на місяць.\nЗростання цін на нерухомість у найближчі п\'ять років – 6% на рік.\n8. Кращі види. Саутварк (Southwark) – це ділове Сіті, і хмарочос Shard, і галерея Tate Modern, і найстаріший ринок Borough Market. У Саутварку живуть успішні фінансисти, економісти та дипломати. Цей старовинний район вважається дуже перспективним. Багато змін відбулося завдяки будівництву гілки метро Jubliee. Побудовано багато нових розкішних будинків, розрахованих на молодих фахівців. Ця частина столиці динамічно розвивається.\nСередня ціна будинку – £ 555 849.\nСередня орендна плата – £ 1685 на місяць.\nЗростання цін на нерухомість у найближчі п\'ять років – 5,5% на рік.\n9. Долина підгузників (Nappy valley). Вандсворт (Wandsworth) ідеально підходить для сімейного життя, якщо не брати до уваги те, що район дорогий. Тут знаходиться найбільша кількість хороших початкових шкіл та інших навчальних закладів британської столиці. Історія деяких з них налічує десятиліття. Вандсворт вважається одним із найбільш обжитих районів Лондона.\nСередня ціна будинку – £ 512 515.\n\"', 2, '2015-08-19 16:37:56', 'post_image-35.jpeg', 98),
(29, '65% частных островов в мире стоят дешевле $500 000', 'Согласно исследованию компании о состоянии мирового рынка частных островов и элитной курортной недвижимости, расположенной на островах и архипелагах (The Island Review), 65% частных островов в мире стоят дешевле $500 000.\nТак, цены в мире варьируются от $30 000 за небольшие острова в Канаде до $60-70 миллионов за острова на Багамах и Филиппинах и до $100 миллионов в Мексике.\n  Наибольший рост цен на премиальную курортную недвижимость на островах в 2014 году был зафиксирован на Бали (+15%), Мюстике (+5%) и Ибице (+5%).\n  Острова Центральной Америки (Панама, Коста-Рика, Белиз) и Азиатско-Тихоокеанского региона (Филиппины, Тонга) являются наиболее перспективными направлениями для развития островной курортной недвижимости.\n  В Карибском регионе в результате глобального финансового кризиса большое число девелоперских проектов в 2008-2009 годах было заморожено. В большей степени пострадали острова, на которых велось строительство недвижимости среднего ценового сегмента, например, Теркс, Кайкос, Ангилья и Сент-Люсия. Однако, рост числа туристов после 2011 года привел к увеличению объемов продаж, а усиление доллара с середины 2014 года вызвало рост заинтересованности инвесторов.\n  В Азии постепенно набирает обороты тенденция приобретения курортной недвижимости в качестве «второго дома». Ожидается, что этот тренд значительно усилится через пять лет и окажет влияние на глобальный рынок недвижимости. Бали, Пхукет и Фиджи являются наиболее зрелыми рынками островной недвижимости, но при этом остаются в большей степени туристическими направлениями, чем точками развития люксовой курортной недвижимости в западном понимании.\n  Вместе с тем, по оценкам компании, лишь 5% от общего числа частных островов в мире считаются качественной недвижимостью: это объекты, обладающие хорошей транспортной доступностью, обеспеченные электричеством и канализацией, относящиеся к странам со стабильным политическим режимом и, что важно, имеющие развитую медицину.\n  Приобретением частных островов интересуются не только крупные предприниматели и мировые знаменитости, но и неправительственные организации, фонды по защите окружающей среды с целью сохранения уникальных экологических систем, а также правительства государств, развивающие курортные направления для экономики своей страны. Число покупок островов этими группами интересантов за 10 лет выросло на 283%.', 2, '2015-09-22 14:44:26', 'post_image-36.jpeg', 34),
(30, 'Это не индийские храмы. Это подземные колодцы невероятной красоты', 'На территории Индии находится большое количество медленно разрушающихся потрясающих архитектурных сооружений. Многие из нас даже никогда не слышали о них. Речь идет о необыкновенных каменных колодцах глубиной до десяти этажей. \n  Тысячи колодцев были построены в Индии между вторым и четвертым столетиями н.э. как обычные рвы, которые постепенно развились в гораздо более сложные достижения инженерии и искусства. Колодцы стали символом вечной жизни, их строили богатые и могущественные филантропы, среди которых было немало женщин. \n  Конструкция подземного колодца представляет собой глубокий цилиндр для получения подземных вод. Для удобства доступа к воде рядом был размещён смежный каменный ров с длинной лестницей и боковыми выступами, где через специальное отверстие вытекала вода. А в сезон дождей колодцы превращались в огромные цистерны, заполняясь водой до отказа. Это оригинальная система сохранения воды использовалась на протяжении целого тысячелетия.\n  Неконтролируемое выкачивание грунтовых вод привело к высыханию большинства колодцев. На сегодняшний день многие из них полностью заброшены.\n  Небольшое количество сооружений, находящихся неподалёку от туристических маршрутов, поддерживаются в хорошем состоянии. Но большинство из этих уникальных объектов давно заросли, частично обрушились либо используются в качестве мусорных свалок. Многие из них, к сожалению, уже навсегда исчезли со всех карт.', 2, '2015-09-22 14:54:29', 'post_image-37.jpeg', 12),
(31, 'Каркасная технология строительства: быстро и экономно', 'В последнее время все чаще при выборе технологии строительства частного дома владельцы отдают предпочтение каркасной технологии.\nЭксперты объясняют этот факт тем, что при использовании данной технологии строительства можно существенно сократить сроки возведения строения и при этом существенно сэкономить.\n  Основные преимущества каркасной технологии.\nСтоит отметить, что каркасная технология является, в некотором роде, старожилом среди наиболее популярных технологий возведения частных домов и коттеджей. Она была придумана канадцами еще в начале 19 века и длительное время успешно применялась в Канаде и других странах мира.\n В 50-60-х домах эта технология появилась и успешно использовалась для быстрого строительства небольших частных домов и на территории Украины. Но с учетом того, что строительные материалы, такие как кирпич, дерево, бетон были не очень дорогими, предпочтение при строительстве домов отдавалось именно им. И со временем о каркасной технологии в нашей стране практически забыли.\n  Новый виток развития каркасной технологии в Украине начался в период активного развития строительства частный домов, который начался в 2000 году. В этот период каркасная технология строительства позиционировалась как одна из наиболее теплосберегающих технологий из существующих технологий возведения деревянных домов.\n  По словам представителей компаний, продвигающих эту технологию на территории Украины, благодаря использованию каркасной технологии строительства при возведении дома удается существенно снизить расход древесины, при этом значительно улучшив теплозащитные свойства конструкции. По данным специалистов, теплоизоляционные свойства стен каркасного дома соответствуют кирпичной кладке толщиной в 2 метра.\n При этом, варьируя различными видами утеплителей, можно использовать одни типы домов в разных районах страны, даже с самым суровым климатом. Это доказано такими странами как Канада и Финляндия, которые отличаются своими суровыми климатами и где каркасная технология является наиболее используемой.\n К слову, в нашей стране особый интерес каркасные дома представляют для удаленных районов, где  остро стоит вопрос снижения веса и объема привозных строительных материалов, а также комплектации строительства местными материалами.\n  Но одним из основных преимуществ каркасной технологии строительства является то, что дома, возведенные по этой технологии достаточно легкие, поэтому не требуют обустройства очень массивного, а значит - дорогого, фундамента.\n  Стоит отметить, что современный каркасный дом состоит из элементов, которые в большинстве своем выполнены на заводах и поставляются на место строительства практически в готовом виде. Поэтому строительство каркасного дома скорее напоминает сборку готовых компонентов. Благодаря этому, сам процесс возведения дома является достаточно быстрым.\n  Сам процесс возведения каркасного дома выглядит следующим образом: сначала возводится каркас дома, согласно проекту; затем каркас утепляется после чего \"обшивается\" плитами. Это могут быть как фибролитовые плиты, так и усиленный гипсокартон. В настоящее время наиболее часто используются ОSB-плиты. После \"обшивки\" плитами, готовые стены готовы к чистовой отделке.\n  Стоит отметить, что в настоящее время многие производители предлагают обшивать каркас готовыми утепленным плитами, которые представляют собой готовые многослойные конструкции с утеплителем, так называемые панели-сэндвич. Важным их плюсом является то, что стены, выполненные из этих панелей не требуют дополнительной наружной отделки.\n  Важным нюансом каркасной технологии строительства является то, что в процессе возведения практически отсутствуют \"мокрые\" строительные процессы. Поэтому строить дома по этой технологии можно даже зимой.\n  В настоящее время некоторые мировые проектировщики и строители соревнуются в том, кто наиболее быстро построит каркасный дом. Самым лучшим результатом на сегодняшний день являются результаты финских строителей, которым удается строить дома по этой технологии в течении 10 дней.\n  Важно отметить, что именно скорость возведения каркасных домов и их сравнительно невысокая стоимость делает их востребованными у отечественного заказчика. Конечно, ради справедливости стоит отметить, что данная технология строительства частных домом еще не настолько популярна в Украине, как у себя на родине. Хотя, по словам экспертов, для этой технологии все еще впереди.', 2, '2015-09-22 15:36:13', 'post_image-38.jpeg', 6),
(33, 'Рейтинг самых дорогих частных домов мира', 'Нет предела совершенству и невероятным тратам на роскошные особняки. Сегодня мы с Вами рассмотрим пять самых дорогих частных домов мира. \n\n5-е место – Кэнсигтон Пэлэс Гарден 18-19, Лондон - $222 миллиона. Особняк расположен на самой богатой улице Лондона, также известной как «Ряд Миллионеров», на которой также находятся дома самых знаменитых и влиятельных англичан, например, принца Уильяма. Особняк принадлежит Лакшми Миталл, сталеварному магнату, главе сталепроизводительной компании «Арселор Миталл». В нем есть 12 спален, 18 ванных, крытый бассейн, паркинг на 20 машин и турецкая баня.\n\n4-е место - особняк «Пруд Фэрфилд», Нью-Йорк – $250 миллионов. Крупнейший жилой комплекс США, занимающий площадь в 25,5 гектаров, принадлежит Айре Ренерт, американскому инвестору и бизнесвумен, основательнице группы компаний Renco. Площадь зданий составляет 10 000 кв.м., из них главное здание – 6 000 кв.м., которое включают в себя 29 спален, 39 ванных. На территории размещены также кегельбан, корты для сквоша и тенниса, бассейн с подогревом, банный комплекс, персональная электростанция, которая обеспечивает особняк электричеством.\n\n3-е место – Вилла Леопольда, Лазурный берег, Франция - $750 миллионов. Эта вилла была построена в 1902 году для любовницы короля Бельгии Леопольда II. Но в 1909 году, после смерти короля, она была изгнана из своего дома. Сейчас особняк принадлежит Лили Сафра, вдове банкира Эдмонда Сафра, погибшего в 2003 году. Здесь есть 19 спален, теннисные корты, спортивные площадки, боулинг, несколько кухонь и столовых, собственный кинотеатр, а уникальный ландшафтный парк ежедневно обслуживают более 50 садовников.\n\n2-е место – вилла «Антилла», Мумбаи, Индия – 1 миллиард. Особняк высотой в 27 этажей принадлежит миллиардерам Мукешу Амбани и Ните. Здание занимает площадь более 3 700 кв.м. В здании курсируют девять лифтов, из них два предназначены для персонала, который составляет 600 человек. Здание разделено на несколько частей: четверть предназначена для размещения гостей, есть также шестиэтажный гараж для машин членов семьи миллиардеров, гостей и рабочих. На крыше особняка расположены три вертолетные площадки. Земля, на которой построен особняк, предназначалась для строительства школы для бедных детей.\n\n1-е место – вилла в Альпах, точный адрес не разглашается – 12,2 миллиарда. Трудно поверить, что вилла площадью всего 750 кв.м. может стоить так много! Невероятная стоимость здания выплывает из стоимости материалов, из которых построен особняк. Вы будете удивлены, но при строительстве использовалось настоящее золото и платина, космические метеориты и даже кости динозавров, которые несут огромную историческую ценность. В доме всего восемь спален и 6 ванных комнат, а также терраса площадью 388 кв.м. Виллу запрещено фотографировать и снимать на пленку.', 2, '2015-09-24 10:52:37', 'post_image-39.jpeg', 30),
(34, 'Как купить коммерческую недвижимость по лучшей цене: 9 советов покупателям', 'На сегодняшний день рынок коммерческой недвижимости в Украине огромен и насыщен предложениями. Предприниматели и представители организаций каждый день выставляют сотни вариантов помещений, магазинов, складов. Запутаться в этом немудрено, тем более что ценовой диапазон широкий, разный и уровень самой недвижимости.\nЧто такое коммерческая недвижимость?\nПод коммерческой недвижимостью понимают любое помещение, в котором ведется бизнес. Это может быть как небольшой офис 4 на 4, так и огромный торговый центр. В принципе, при приобретении такой недвижимости действуют определенные правила, которых стоит придерживаться, чтобы бизнес был доходным, а покупка была не разорительной.\nСоветы по покупке коммерческой недвижимости\n1. Дешево - не всегда хорошо. Не гонитесь за наименьшей ценой\nНе стремитесь купить дешевую недвижимость, особенно, если до вас там располагался бизнес вашего же профиля, скорее всего, место не «хлебное». Ну, или есть «подводные камни» в виде придирчивой налоговой, постоянных проверяющих или еще каких-то, незаметных сейчас, проблем.\n2. Время имеет значение. Посетите здание в разное время суток.\nОбязательно побывайте в своей будущей недвижимости в разное время суток. При разном типе освещения можно увидеть разные проблемы, недостатки и ,конечно, новые достоинства. Особенно это актуально для коммерческой недвижимости, предполагающей частое присутствие клиентов и партнеров.\n3. Доверяй, но проверяй\nЗаймитесь проверкой права собственности на недвижимость самостоятельно или через знакомого риэлтора. Не поддавайтесь на речи продавцов, сулящих обязательное переоформление, подайте заявление на определение собственника в Укргосреестр. За небольшую денежную сумму вы получите точное подтверждение честности продавца.\n4. Проверьте права на земельный участок\nЕсли недвижимость отдельно стоящая, то проверять надо будет и права на пользование земельным участком. Если земля под строением взята в аренду у государства, то такая недвижимость будет стоить дешевле, а вам необходимо приготовиться к дополнительным расходам в процессе ведения бизнеса.\n5. \"Дьявол кроется в мелочах\". Проверяйте детали сделки\nУточните все детали продажи, особенно, если это необычное приобретение, а, например, рассрочка с арендой и последующим полным выкупом. Когда вам передадут все документы на покупку, как будет оформляться передача собственности, сколько надо внести предварительно средств. Особенно внимательно читайте пункт о возможной конкуренции при покупке, вдруг вы уже отдадите достаточную сумму, а появится кто-то, желающий заплатить больше, и собственник «переметнется».\n6. Оцените выгоду от покупки\nОцените будущие вложения в недвижимость, стоимость ремонта и переоборудования. Проверьте возможные прибыли и потенциальные расходы на рекламу именно в этом районе. Сложите эту сумму с суммой покупки. Часто самые дешевые помещения под офис при такой проверке оказывается совсем не дешевыми.\n7. Позаботьтесь о презентабельности помещения\nОсматривайте не только помещение, которое планируете использовать. При первом приезде посмотрите, есть ли парковка, удобна ли она для клиентов и сотрудников, как выглядит вход. Все это будет в будущем создавать впечатление о вашем бизнесе, не пренебрегайте этими вещами. Спросите, есть ли охрана у недвижимости, кто платит за ее услуги, довольны и собственники качеством услуг.\n8. Не торопитесь с покупкой\nНе покупайте первую попавшуюся вам коммерческую недвижимость, присмотритесь, не торопитесь, чтобы потом не пожалеть о покупке.\n9. Наймите профессионала\nКонечно же лучше обратиться к услугам агентства, знакомого брокера или риэлтора. Дайте задание, заплатите комиссионные, поверьте, что это обойдется дешевле, чем всю эту дорогу вы пройдете сами. Не ищите коммерческие площади методом «сарафанного радио».\"', 2, '2015-10-08 13:09:21', 'post_image-41.jpeg', 110),
(35, 'Четыре распространенных заблуждения об эксклюзивном договоре с риэлтором. Часть 1', 'Большинство владельцев недвижимости хотят воспользоваться помощью риэлтора в продаже, но часть из них при этом не хотели бы заключать никаких договоров, особенно эксклюзивных, т.е. дающих исключительное право одному риэлтору (компании) представлять интересы владельца недвижимости при его продаже/аренде.\nВот четыре распостранённых заблуждения, которые мешают эффективной продаже любого объекта недвижимости:\n\nЕсли заключить договор с одним риэлтором - он приведёт меньше покупателей, а следовательно я продам свою недвижимость дешевле.\n\nУвы, от количества риэлторов и объявлений число реальных покупателей на рынке не увеличивается. Чего действительно будет больше, так это звонков. Звонков от риэлторов! Ведь не занимаясь продажей вашего варианта вплотную и, плохо ориентируясь в вашем объекте, они (агенты) будут постоянно звонить, уточнять характеристики, цену и актуальность вашего объявления.\n\nА вот один, но хороший и мотивированный вами (!) риэлтор, уверенно владеющий инструментами продвижения объектов недвижимости на рынке, правилами ведения переговоров, правилами торга, имеющий заранее подготовленную презентацию объекта, хорошие фото и видеоматериалы по объекту, умеющий составлять продающий текст объявления и при этом, сосредоточивший весь спрос на объект в своих руках, в том числе и от покупателей, имеющихся у своих коллег по цеху, в итоге, приведёт к вам всех (ну или почти всех) покупателей с рынка! И далее, действуя в ваших интересах (ибо в данном случае его мотивация исходит от вас, а не от покупателя), поможет вам продать объект дороже.\n\nЕсли я найду покупателя/арендатора самостоятельно, они откажутся покупать, если узнают, что у меня заключен договор с риэлтором, так как не захотят оплачивать его услуги.\n\nС такой постановкой вопроса стоило-бы согласиться. Если бы не одно важное замечание. Не заключайте бесплатных эксклюзивных договоров! Это ловушка для владельцев! Бесплатный договор морально легче заключить и именно на это направлена его бесплатность. Однако, к “несчастью” владельцев, при продаже недвижимости риэлторы не занимаются благотворительностью, и при бесплатном для вас договоре, свою комиссию они “вешают” на покупателя, при этом приводя на показ только тех из них, кто согласен её оплачивать.\n\nПри каких условиях, покупатель соглашается оплатить комиссию риэлтора, за услуги, которые фактически оказываются вам, а не ему, оставляю додумать самостоятельно.\n\nА вот в ситуации, когда услуги по договору оплачиваете вы, как и должно быть по законам логики (ведь риэлтор работает на вас), ни один покупатель не откажется смотреть объект, ведь он не несёт дополнительных расходов. Всё что вам необходимо сделать, это сообщить покупателю примерно следующее: “Спасибо за ваш звонок! Да я продаю объект. Стоимость такая-то. Конечно можно посмотреть, сейчас с вами свяжется мой риэлтор и обсудит с вами детали показа.” При этом некоторые покупатели могут конечно посопротивляться, ведь многие из них привыкли (к сожалению), что при этом им прийдется платить риэлтору. Поэтому успокойте их заранее, что никаких дополнительных расходов они не несут ибо услуги риэлтора оплачиваете вы. При такой постановке вопроса потерь в количестве, а, главное, в качестве покупателей не произойдёт.\n\nЕсли у другого риэлтора будет покупатель, он может не привести его, так как не захочет делить свою комиссию пополам с моим риэлтором.\n\nРиэлтор у которого есть покупатель, которому потенциально подходит ваш объект недвижимости в подавляющем большинстве случаев его всё же приведёт. Прежде всего это произойдёт в силу двух наиболее существенных причин:\n\nВо-первых, утаив информацию, которая потенциально может быть интересна его клиенту, риэлтор рискует тем, что клиент обнаружит её самостоятельно и агент в этом случае не получит вообще ничего, кроме разумеется потери доверия со стороны своего клиента.\n\nА во-вторых: риэлтор покупателя будет рад получить половину гарантированного вознаграждения от риэлтора со стороны собственника, так как со стороны покупателей наблюдается тенденция снижения как желания оплаты услуг, так и снижения размера этой оплаты, особенно сейчас на не самом бодром рынке.\n\nНа самом деле, вопрос сотрудничества риэлторов уже давно решён в пользу его необходимости. Поэтому нормальные риэлторы не станут рисковать своей репутацией и заработком (пусть и половинчатым) и скрывать наличие на рынке подходящего, но эксклюзивного объекта. Попутно хочу обратиться к покупателям недвижимости: если ваш риэлтор показывает вам только прямые объекты, скорее всего он злоупотребляет вашим доверием и скрывает самое интересное. Смените риэлтора!\n\nЕсли я передумаю продавать, по договору я должен буду заплатить штраф.\n\nВот на этом стоит остановиться подробнее. А как вы относитесь к ситуации, что если вы передумаете, то риэлтор потеряет время и деньги? Если вас это не волнует и вероятность, что вы все таки передумаете высокая, то скорее всего вам действительно не нужно заключать никаких договоров, тратьте только своё время и только свои деньги. Это будет честно.\n\nА если всё же вы считаете справедливым на берегу договориться со своим риэлтором, как именно вы разойдётесь с ним в случае, если передумаете продавать, то заранее оговорите приемлемый для вас вариант неустойки или штрафа и проследите, чтобы в договоре это было отражено корректно.\n\nНа самом деле начинать продажу, имея сомнения в том, что вы доведёте задуманное до конца, не стоит. И это относится не только к недвижимости, а и ко всему.\n\nПредставьте себе, что вы надумали построить дом, пошить костюм, постричься, пообедать в ресторане и т.д. Бригада каменщиков выгнала первый этаж, швея раскроила ткань, парикмахер состриг половину волос, вы уже съели первое блюдо и... передумали. Кто в этом случае должен заплатить за фактически проделанную работу? Если чувство справедливости вам не чуждо, то согласитесь, - вы! Почему же в случае с риэлтором должно быть иначе?\n\nА вот ситуацию, когда вы просто хотели бы застраховаться от недобросовестной работы риэлтора — считаю справедливой. Рекомендую оговорить в договоре испытательный срок, в течение которого при отсутствии результата и видимости работы со стороны вашего риэлтора, вы могли бы расторгнуть договор в одностороннем порядке без штрафных санкций с вашей стороны. Вот это логично. Особенно, когда речь идёт о небольшом сроке, например в первые две недели.\n\nДля того, чтобы удачно продать свою квартиру или дом, рекомендую получить больше информации из разных источников. При этом общайтесь не только со знакомыми, особенно не имеющими, к недвижимости прямого отношения, но и с разными риэлторами. Устройте конкурс, ориентируйтесь на предварительную оценку вашего объекта, как правило оценка добросовестного специалиста вам не понравится, а услуги будут платными. Поинтересуйтесь предлагаемыми технологиями для достижения максимального результата, не “ведитесь” на пустые обещания, не подкреплённые ничем, кроме эмоций. Ориентируйтесь также на потраченное специалистом время до заключения договора (у профи оно будет всегда значительнее чем у обещалкина). Удачной вам продажи!', 2, '2015-10-08 14:04:26', 'post_image-42.jpeg', 118),
(36, 'Самое распространенное заблуждение об эксклюзивном договоре с риэлтором. Часть 2', 'Самое распространённое заблуждение (по мнению автора), которое мешает продаже объекта недвижимости по максимальной рыночной стоимости: если заключить договор с одним риэлтором - он расслабится и будет плохо работать, так как не будет чувствовать конкуренцию со стороны других риэлторов.\nНа первый взгляд это логично. Давайте разберёмся как на самом деле. Конкуренция между риэлторами за право поскорее предложить покупателю именно ваш объект действительно возможна, но лишь в двух случаях.\n\nПервый: вы обладатель уникального объекта, единственного в своём роде и при этом пользующегося высоким спросом. Это не так?\n\nТогда проверяемся по второму условию: вы значительно занизили цену на свою недвижимость по сравнению с конкурентами. И это не так?\n\nНу что же, поздравляю, вы в тренде! Так как владельцев, отвечающих двум вышеперечисленным условиям менее пяти процентов рынка - вы являетесь среднестатистическим владельцем недвижимости и желаете её продать подороже.\n\nИтак ваша недвижимость не самая дефицитная, не слишком дешевая, филантроп - это не про вас, вы не адский везунчик, а все ваши конкуренты -владельцы подобного имущества живы - здоровы. Добро пожаловать на планету Земля!\n\nПри не заключенном договоре, т.е. не имея никаких гарантий заработка от продажи именно вашей недвижимости, риэлтор вообще не станет напрягаться, ведь у него нет ни перед вами, ни даже перед своей совестью, совершенно никаких обязательств.\n\nДля тех владельцев, кто всё же угодил в счастливчики и попал в пятипроцентный дешевый дефицит, сообщу: риэлторы действительно возможно будут стремиться без всякого договора с вами давать рекламу о продаже вашей недвижимости.\n\nНо сделают это не потому, что мечтают продать именно вашу квартиру или дом, а с целью перехвата трафика входящих звонков покупателей. То есть конкуренция на самом деле существует большая, но не за право продавать вашу недвижимость, а за возможность с помощью привлекательного объекта -наживки перехватить входящий звонок покупателя, интересующегося ею. Кстати именно эта причина, а именно - желание обладать уникальным предложением по нереально низкой цене, для перехвата трафика звонков, и побуждает недобросовестных (мнение автора) агентов, размещать объявления -болванки , т.е. вымышленные объекты с привлекательными характеристиками.\n\nОднако, поскольку от повышения количества объявлений число покупателей на рынке, увы, не увеличивается, то что на одно, что на несколько объявлений, в совокупности отреагирует одинаковое количество покупателей, но позвонят они тому риэлтору, кто:\n\n- установит в объявлении самую низкую цену на ваш объект;\n- или пообещает хороший торг в тексте;\n- или так “улучшит” в объявлении характеристики вашего дома или квартиры, что после показа её покупателю у последнего, в лучшем случае, останутся разочарования, в худшем - пара нецензурных выражений и риэлтору и вам до кучи.\n\nКак вам перспектива такой риэлторской “конкуренции”?\n\nИзобилие клонов объявлений с разной ценой, текстом и фотографиями ведёт к неконтролируемому снижению цены на объект, как в силу гонки по перехвату звонков покупателей посредством более низкой цены в объявлении, так и в виду ослабления эффекта уникальности (эксклюзивности) предложения на рынке. Вот откуда, кстати, и вытекает распространенное название договора оказания услуг по продаже недвижимости. И вот почему эксклюзивность является желаемой не только для агента, но и для владельца. Для получения максимально возможной цены продажи недвижимости.\n\nА вот, что действительно имело бы смысл сделать, чтобы риэлторы не расслаблялись, так это устроить тендер между ними за право заниматься продажей вашей недвижимости на самом предварительном этапе, а затем выбрать одного - самого лучшего, на ваш взгляд, специалиста, и уже ему доверить продажу вашей недвижимости. Ведь риэлторы должны конкурировать между собой лишь до заключения договора, а после этого — только сотрудничать.\n\nЕдинственный, но самый важный вопрос, который остаётся -это как выбрать лучшего риэлтора. Прочтите статью \"ХОТИТЕ ПРОДАТЬ НЕДВИЖИМОСТЬ? ПОЧУВСТВУЙТЕ СЕБЯ КЛИЕНТОМ!\". Если лень читать, то хотя бы воспользуйтесь правилом: ориентируйтесь не на обещания риэлтора “сделать вам хорошо”, а на его объяснения почему именно он справится с продажей лучше других.\nПослесловие\n\nВ целом, уважаемый читатель, любые заблуждения и стереотипы являются следствием недостатка и однобокости получаемой информации. В большинстве случаев кстати полученной от неспециалистов, а также знакомых, которым “не повезло”.\n\nНо ведь заблуждения встречаются во всех сферах жизни, а не только в операциях с недвижимостью. Так что не будем делать из этого трагедию. А просто не спеша и вместе во всём разберёмся. Удачной вам продажи!\"', 2, '2015-10-08 14:40:33', 'post_image-44.jpeg', 113),
(37, 'Что такое рассрочка от застройщика?', 'В последнее время рассрочка от застройщика становится популярным способом приобретения недвижимости. Практически каждый житель Украины может позволить себе квартиру в еще недостроенном доме. Но действительно ли такая рассрочка будет выгоднее ипотеки? \nРазнообразные программы рассрочки предусмотрены практически у всех крупных застройщиков. Мелкие строительные фирмы также имеют свои условия, но их преимущество заключается в разработке индивидуальных схем для каждого клиента. Так что такое рассрочка от застройщика? Чем она отличается от ипотечной и какие виды рассрочек предлагают строительные фирмы?\nЧем отличается рассрочка от ипотеки на жилье?\nУсловия рассрочек от застройщика куда выгоднее ипотеки, ведь предоставляются они без процентов и поручителей. Главное условие – первоначальный взнос. Таким образом, застройщик увеличивает спрос на свои проекты и экономит на их строительстве, ведь, по сути, приличную часть расходов покроют деньги, полученные при совершении сделок с клиентами.\nОсновная часть рассрочек относится к приобретению квартир еще на стадии их строительства и далеко не все фирмы могут предоставить такую возможность касательно уже сданных в эксплуатацию домов. \nВот несколько украинских банков, предлагающих такой вид рассрочки: «Ковальская» и UDP; «Созидатель» (Днепропетровск); UBC (Донецк).\nИпотека несколько отличается по своим условиям от рассрочки застройщика и имеет несколько минусов:\nДля оформления ипотеки необходимо подготовить большое количество документов. Их сбор отнимет много времени, а сам список документов следует уточнять у представителей банка.\nИпотека оформляется на длительный срок (до 30 лет).\nВыплачивая ипотеку, заемщик рискует переплатить большую сумму денег.\nПеречисленные минусы не относятся к рассрочке от застройщиков. Для ее оформления просто подписывается договор купли-продажи, согласно которому квартира становится предметом залога. \nПокупатель вносит первоначальный взнос и выплачивает оставшуюся сумму до окончания оговоренного срока.\nОсобенности рассрочки от строительных фирм\nРассрочка от застройщика имеет свои особенности. \nКороткий срок выплаты, всего 2-3 года. Главным условием в договоре со строительной фирмой - это успеть выплатить полную сумму до сдачи дома в эксплуатацию. Так, например, приобретая жилье стоимостью в 400 тысяч гривен, которую планируют сдать в начале 2016 года, сначала вносится первый взнос (примерно 25%), и далее вы должны выплачивать по 100 тысяч гривен. каждый месяц. Поэтому важно обращать внимания на сроки выполнения строительных работ, прописанных в договоре.\nЕще один минус такой рассрочки в том, что не все фирмы фиксируют цену 1 м2 в договоре и могут изменить ее в ходе постройки дома. Многие застройщики, например, «Познякжилстрой»,установят цену на 1 м2 только при 50% первом взносе.\nВ случае рассрочки от застройщика не исключены переплаты, но многие фирмы решают эту проблему, делая скидки в размере 2,5–5%. Правда, это относится только к тем клиентам, которые выплатили всю сумму за квартиру сразу же, а значит, большинству все равно не избежать переплат.\nКакие виды рассрочек предлагают застройщики?\nСтроительные фирмы предоставляют рассрочку по двум направлениям:\nЗа счет собственных усилий. \nПри помощи банка.\nПервый способ наиболее удобный. На этапе постройки дома, застройщики предлагают условия рассрочки, при которых установленные выплаты не будут увеличиваться. Первый взнос будет составлять от 10% до 50% (это зависит от фирмы и ее условий), а остаточные взносы будут равномерно разделены до окончания срока выплат (это может быть каждый месяц, каждые 4 месяца и т.д.)\nЕсли с рассрочкой от застройщика все более-менее понятно, то как быть с «партнерским кредитом»? Когда у строительной фирмы нет возможности самостоятельно реализовать свои проекты, она обращается за сотрудничеством в банк. Некоторые фирмы связаны с ним напрямую «Аркада», «Укрсоцстрой», а другие сотрудничают с банками для того, чтобы те выдавали кредиты и рассрочки именно на их проекты «Лико-Холдинг».\nКонечно, «партнерский кредит» обойдется покупателю дороже, чем рассрочка от заемщика, но такая система имеет и свои плюсы:\nДлительный срок кредитования, до 20 лет.\nПроцентная ставка ниже на 2%-3%, чем при ипотеке.\nПолучить такой кредит можно на стадии постройки дома, а оплату внести полностью и получить за это хорошую скидку.\nПеред совершением сделки покупки жилья по рассрочке оцените свои финансовые возможности, внимательно изучите все документы, а главное, выберите добросовестную, с хорошей репутацией, строительную фирму.', 2, '2015-10-14 02:18:49', 'post_image-45.jpeg', 104),
(38, 'Какие документы по недвижимости украинцы могут оформить онлайн', 'На портале государственных услуг igov.org.ua был обнародован список услуг, получение которых доступны онлайн.\nКакие услуги украинцы уже сейчас могут получить онлайн:\n\nПредоставление выписки из технической документации о нормативной денежной оценке земельного участка.\n\nПредоставление справки о пребывании на квартирном учете при горисполкоме по месту жительства и в жилищно-строительном кооперативе.\n\nПредоставление справок незанятому населению об отсутствии земельных участков для ведения ОСГ.\n\nАварийный разрешение на проведение земляных работ.\n\nПостановка на учет граждан, нуждающихся в улучшении жилищных условий.\n\nВыдача сведений из документации по землеустройству, которая включена в местный фонд документации по землеустройству.\n\nВыдача справки о реагировании общественности на заявление о намерениях по строительству или реконструкции объектов на территории города.\n\nПредоставление сведений из Государственного земельного кадастра в форме выписки из Государственного земельного кадастра о земельном участке.\n\nПредоставление справки из Государственной статистической отчетности о наличии земель и распределении их по владельцами земель, землепользователями, угодьями (по данным формы 6-ЗЭМ).\n\nПредоставление справки о наличии и размере земельной доли (пая), справки о наличии в Государственном земельном кадастре сведений о получении в собственность земельного участка в пределах норм бесплатной приватизации по определенному виду ее целевого назначения (использования).\n\nПредоставление справки о пребывании на учете желающих получить земельный участок под индивидуальное строительство.\n\nПредоставление справки о пребывании на учете граждан, нуждающихся в соответствии с законодательством в улучшении жилищных условий.\n\nПредоставление справки об участии в приватизации жилья государственного жилищного фонда.\"\"', 2, '2015-11-02 20:46:38', 'post_image-46.jpeg', 113),
(39, 'Налоги при продаже квартиры: сколько заплатит продавец и покупатель.', 'При подписании договора купли-продажи, согласно украинскому законодательству, и покупатель, и продавец должны платить налоги.\n\nНалоги, которые оплачивает покупатель:\nПокупатель оплачивает только 1% от стоимости квартиры или дома в Пенсионный фонд. Сбор платят как резиденты, так и не резиденты Украины.\nВ украинском законодательстве предусмотрено исключение — не подлежит налогообложению дарение и получение недвижимости по договору пожизненного содержания.\n\nНалоги, которые оплачивает продавец:\nСогласно ст. 172, п.1 Налогового кодекса Украины, продавец оплачивает 1% Государственной пошлины, если недвижимость находилась в собственности более 3 лет. Если квартира находилась в собственности менее 3-х лет или происходила продажа недвижимости чаще одного раза за отчетный налоговый год, владелец при продаже должен уплатить 1% государственной пошлины, 5% налога и 1,5% - военный сбор. Налогом не облагаются объекты недвижимости, которые были получены в наследство по закону или по завещанию.\nЕсли продавец не резидент продает недвижимость, которая была в собственности менее 3-х лет, или происходит продажа недвижимости чаще одного раза за отчетный налоговый год, то необходимо уплатить 1% государственной пошлины, 15% налога на доходы физических лиц (если сумма дохода превышает 10-и кратный размер минимальной заработной платы, применяется ставка 20% налога) и 1,5% военный сбор.\nОт каких налогов освобождаются льготники:\nСогласно статьи 4 Декрета Кабинета Министров Украины «О государственной пошлине», от уплаты госпошлины освобождаются следующие категории граждан:\n- инвалиды Великой Отечественной войны и семьи воинов, которые погибли или пропали без вести и приравненные к ним в установленном порядке лица;\n- инвалиды 1 и 2 группы;\n- граждане, отнесенные к І и ІІ категории пострадавших вследствие Чернобыльской катастрофы;\n- граждане, которые имеют статус пострадавшего в следствии аварии на ЧАЭС третей категории, которые по состоянию на 1 января 1993 года жили или работали в зоне обязательного отселения не меньше двух лет, а в зоне гарантированного добровольного отселения не меньше трех лет;\n- граждане, которые имеют статус пострадавшего в следствии аварии на ЧАЭС четвертой категории, постоянно проживают или работают в зоне повышенного радиоэкологического контроля, при условии, что по состоянию на 1 января 1993 года они прожили или отработали в этой зоне не меньше 4 лет.\nВоспользоваться льготой можно при оформлении сделки у государственного нотариуса. Если один из участников сделки освобождается от уплаты госпошлины, то ее платит второй участник. В случает оформления сделки двумя льготниками, от уплаты пошлины освобождаются обе стороны.', 2, '2015-11-21 11:07:40', 'post_image-47.jpeg', 1);
INSERT INTO `posts` (`id`, `title`, `content`, `author_id`, `date`, `image`, `views`) VALUES
(40, 'В чем реальный смысл моратория на землю', 'Запрет на продажу сельхозземель продлен еще на год. Кому это выгодно и сколько будет стоить украинскому агросектору.\nНа прошлой неделе Верховная Рада 309 голосами продлила мораторий на отчуждение сельскохозяйственных земель до 1 января 2017 года. При этом депутаты взяли обязательство разработать законопроект об обороте земель сельскохозяйственного назначения до 1 марта 2016 года.\n  Мнения аграриев относительно принятого парламентом решения разделились: одни считают его очередной ошибкой, лишающей селян их законного права собственности, а агросектор - шанса на качественное развитие, другие доказывают, что преступлением против Украины была бы его отмена. Вопрос очень политизирован и оброс невероятным количеством мифов. \n\nТайны моратория:\nК сожалению, многие эксперты, которые берутся рассуждать о земельном вопросе, плохо понимают, что собой представляет мораторий. Об этом свидетельствует, в частности, распространенная точка зрения, согласно которой мораторий истекает 1 января 2016 года, а также внесение законопроектов, призванных \"продолжить\" мораторий, и их обсуждение на полном серьезе. Создается впечатление, что народные депутаты, которые пишут законы, с действующим законодательством не знакомы. \nНа самом деле 1 января 2016 года действие моратория не заканчивается. Мораторий предусмотрен сегодня Переходными положениями Земельного кодекса. В частности, в них содержится информация о том, что до вступления в силу закона об обороте земель сельскохозяйственного назначения, но не ранее 1 января 2016 года, разрешить продажу земли нельзя. \n\nОднако из общего правила есть несколько исключений. Не запрещено:\n- отчуждать участки сельхозназначения государственной и коммунальной собственности, которые выкупаются для общественных потребностей;\n- продавать сельскохозяйственные наделы, которые передаются по наследству;\n- менять земельный участок на другой зем.участок для общественных нужд;\n- изменять целевое назначение земельных участков с целью предоставления их инвесторам - участникам соглашений о разделе продукции для осуществления деятельности по таким сделкам.\n  Таким образом, автоматического снятия моратория 1 января 2016 не произойдет, и продлевать его, собственно говоря, нужды нет. Ведь закон не препятствует возврату участков в государственную или коммунальную собственность с последующим перераспределением в пользу заинтересованного лица. Эти исключения успешно применяются тогда, когда у инвесторов возникает желание использовать земли сельскохозяйственного назначения для несельскохозяйственных нужд - строительства автозаправочной станции, предприятия, логистического центра, коттеджного городка и т.п. Вместе с тем высокие трансакционные издержки не позволяют использовать \"лазейки\", когда речь идет о дальнейшем сельскохозяйственном использовании участков. То есть мораторий на самом деле касается именно тех, кто желает заниматься сельским хозяйством. \n  Отмечу, что положение о моратории с момента его введения в 2001 году изменялось неоднократно, в законе всегда были какие-то исключения, которые позволяли отчуждать сельскохозяйственные земли для несельскохозяйственных нужд.\n\nПлюс земельного моратория:\nВ защиту моратория на продажу земли могу привести следующий аргумент. Сегодня средний размер земельного пая составляет около 4 га, количество паев в Украине немного меньше 7 млн. Не секрет, что обрабатывать 4 га вручную - слишком тяжелый и экономически неэффективный труд. Но и обрабатывать 4 га с использованием техники экономически невыгодно, ведь техника просто не будет окупаться. Аренда техники или кооперация нескольких мелких собственников - не выход, так как обработка с помощью современной техники многочисленных \"кусочков\" слишком дорогостоящая.\n Пожилые крестьяне часто заинтересованы в продаже земельных паев с тем, чтобы улучшить свое имущественное положение и доживать достойно, а не в нищете. Вследствие существования моратория они не имеют возможности сделать это\n\nИ минусы:\nАргументов в пользу свободного рынка земли намного больше. Во-первых, в условиях существования моратория единственный выход для крестьянина - сдача пая в аренду. И отсутствие доступных альтернатив приводит к тому, что арендная плата за земельные паи мизерная - несколько сотен гривень. Хотя можно привести примеры, когда арендная плата составляет около 1000 и даже 2000 гривень за гектар. Это все-таки исключения, и арендная плата может составлять в среднем по району (в Полесье) менее 400 гривень за гектар. К тому же даже 2000 гривень - это всего-навсего $100. Даже такие поступления от арендной платы вряд ли могут существенно изменить имущественное положение крестьянина.\nПомимо этого, крестьяне пожилого возраста, не имеющие наследников, часто заинтересованы в продаже земельных паев с тем, чтобы улучшить свое имущественное положение и доживать достойно, а не в нищете. Вследствие существования моратория они не имеют возможности сделать это. \nТакже отсутствие возможности продажи земли делает невозможным кредитование сельхозпроизводителей под залог земли. Кредитование становится гораздо более рисковым, а значит, менее доступным для аграриев. Вследствие этого сдерживается, с одной стороны, развитие финансовой системы, а с другой - модернизация сельскохозяйственного производства.\n  И наконец, сельскохозяйственные производители сегодня работают на земле, которая не является их собственностью. Вследствие этого они не заинтересованы не только в коренных улучшениях земли (создание лесополос, мелиоративных сооружений и т.д.), но и в экономном ее использовании. В результате в Украине получило массовое распространение такое негативное явление, как несоблюдение севооборотов, использование наиболее прибыльных, но истощающих почву культур (подсолнечника, рапса) несколько лет подряд \n\nМифы моратория:\nВ обществе чрезвычайно сильны опасения, что снятие моратория приведет к ряду негативных последствий, в первую очередь к созданию \"латифундий\" через скупку земли за бесценок олигархами и агрохолдингами. В условиях исключительного измельчения сельскохозяйственных земель в Украине (на паи средним размером 4 га) сформировать массивы, привлекательные для \"корпораций\" и \"олигархов\", в ближайшие годы не удастся. \n  По данным социологических опросов, большинство крестьян не желают продавать землю, тем более \"за бесценок\". Поэтому гипотетическая корпорация по дешевке сможет приобрести разве что набор участков, разбросанных вокруг деревни, которая не представляет ценности для крупнотоварного производства. Делать это - экономическое самоубийство. Следовательно, приобрести землю за бесценок в первую очередь может мелкий фермер, желающий укрепить свое хозяйство. Создание и укрепление слоя таких фермеров - огромное благо для общества, шанс для возрождения села.\n  Гипотетическая корпорация по дешевке сможет приобрести разве что набор участков, разбросанных вокруг деревни, которая не представляет ценности для крупнотоварного производства. Делать это - экономическое самоубийство.\nЧто мешает отмене запрета на продажу земель. Распространено мнение о том, что мораторий может быть снят, но только после наступления определенных условий. Рассмотрим основные факторы, которые считаются препятствиями для снятия моратория. \n\nКоррупция. Есть опасения, что при снятии моратория коррумпированные суды будут использованы для того, чтобы отобрать землю у крестьян. К сожалению, судебная система пользуется очень низким доверием.\n\nХаос в кадастре и его недостаточная наполненность. Состояние Государственного земельного кадастра в Украине оставляет желать лучшего. Впрочем, при всех проблемах с кадастром в Украине почему-то уже длительное время функционирует рынок земель несельскохозяйственного назначения, и рынок неподмораторных земель сельскохозяйственного назначения тоже.\n\nОтсутствие четких правил. О необходимости \"четких правил\" на рынке сельскохозяйственных земель ведут речь с самого момента введения моратория в 2001 году. Сначала его существование законодательно связывалось с необходимостью принятия нового Земельного кодекса, который был утвержден 25 октября 2001 года. Затем - с принятием законов о Государственном земельном кадастре от 7 июля 2011 года, о рынке земель, об обороте земель сельскохозяйственного назначения. \n  Почему же за 15 лет необходимые правила не были установлены? Потому что, на мой взгляд, просто не удалось найти дополнительных механизмов, которые были восприняты как действительно необходимые на рынке земель сельхозназначения.\n  Сегодня в содержание закона об обороте земель сельхозназначения традиционно предлагают включать нормы о запрете на покупку земель иностранцами, ограничении по площади земель, которые могут находиться в собственности одного лица, установлении преимущественного права на приобретение земель сельхозназначения и разрешительного порядка покупки. Также декларируется намерение прописать правила консолидации земель, которые сейчас лишены смысла, поскольку структура собственности на землю в Украине не предусматривает существования у одного владельца нескольких наделов. \n  Беспристрастный анализ аргументов за снятие моратория и против него, на мой взгляд, подтверждает, что этот шаг должен быть сделан как можно быстрее, причем без каких-либо предварительных условий. Что, конечно, не исключает потребности в совершенствовании земельного законодательства и наполнении кадастра, а также борьбы с коррупцией.\n  Не стоит ожидать от снятия моратория немедленных положительных результатов в виде то ли 100, то ли 120 миллиардов инвестиций (такие цифры звучат в СМИ). Впрочем, положительные последствия будут, и безотлагательно. Они будут и в экономике, и, что еще более важно, в социальной сфере. Крестьяне наконец станут настоящими хозяевами своей земли и получат возможность самостоятельно определять свою судьбу на ней.', 2, '2015-11-21 11:29:18', 'post_image-48.jpeg', 12),
(41, 'Предоплата на рекламу недвижимости', 'Собственники недвижимости могут возразить, что никто так не работает и не финансирует риэлторам рекламную кампанию. Да, именно так и есть, но при этом большинство посредников работают вообще не понятно как. Вместе с тем, это же большинство декларирует, что и нет необходимости оплачивать маркетинг, так как они своими силами и средствами сделают все сами. Но какой при этом будет результат? Предлагаю вам понять смысл этих действий и разобраться, кому и зачем в итоге выгодна предоплата на рекламу недвижимости.\n\nКакая эффективность?\n  За счет этого метода можно четко ограничить планирование сроков продаж. Благодаря этому, риэлтор может предложить наилучшие способы презентации объекта, акцентировать внимание именно на этом объекте. Если риэлтор будет за свои деньги рекламировать – то он будет всячески экономить, тем самым эффективность будет минимальна. То есть, если ваш объект попадает в базу из 10-100-1000 объектов, то вы можете, и не надеется на полноценную работу по объекту (достаточно проверено на многих примерах).\n  С качественным маркетингом: достигается повышенный интерес к объекту со стороны потенциальных клиентов → нагнетается спрос и появляется достаточное количество мотивированных к покупке → осуществляется собственником выбор наилучшего предложения → закрывается вопрос по максимально-рыночной цене и в рамках договоренных сроков. Всё казалось бы просто, но не всегда изначально понятно самому собственнику.\n\nРабота с собственником:\nВ начале, изучаются основные вопросы по недвижимости, ценовые ожидания клиента. Очень часто встречаются желаемые, завышенные цены на свои объекты («хотелки»), которые в дальнейшем сбивают с намеченных планов собственника. Мало промониторить стоимость аналогов в рекламе, надо еще понимать, что большинство объектов уже предлагаются с изначально-завышенной ценой, для возможного торга. Необходимо знать статистику продаж за последний период, чтобы создать полную картину о реальном спросе на момент выхода объекта в продажу. Формирование стартовой цены, с которой выходят на рынок, является первым важным пунктом, от которого зависит дальнейшее этапы продажи.\n  Если у клиента не создастся доверия к риэлтору, то и начинать работу с дальнейшим сотрудничеством – нет смысла ни одной из сторон. Клиент должен понимать, на что он идет и чем рискует. За что он платит, вовлекаясь в дальнейший процесс.\n Когда отношения между сторонами сложись, тогда можно полноценно приступать к работе. Собственник с риэлтором планируют рекламу, при этом риэлтор – рекомендует, а собственник – принимает окончательное решение. Предложение для выбора состоит, как правило, из нескольких вариантов проведения маркетинга.\nВиды задействованной рекламы могут быть разными, в зависимости от объекта:\nвидеореклама;\nвнешняя реклама (баннер, растяжка);\nжурналы и газеты;\nинтернет (порталы, рассылка, контекстная реклама);\nлистовки и флаера;\nдругие источники.\nДля более эффективной рекламы необходимо сделать предпродажную подготовку недвижимости.\n\nЗаинтересованность сторон:\nДля кого это, прежде всего, интересно? Какая выгода для собственника, где опасения и какая уверенность – для риэлтора?\n  Собственнику – для эффективной продажи с максимальным результатом. Риэлтору – дополнительный пункт в проявлении лояльности и мотивации собственника на продажу. Обоюдное нивелирование рисков для сторон.\n Собственник своими деньгами добивается лучшего результата. Самостоятельная продажа собственником – может быть не эффективна и не рациональна по использованию рекламным бюджетом. Ведь он без опыта не сможет проанализировать портрет потенциального клиента: что тот читает, где проводит время, какие источники использует для поиска недвижимости?\n  Необходимо понимание, относительно работы по эксклюзиву – так работает один посредник и ему оплачивается рекламный бюджет. И помимо этого, он заинтересовывает все профессиональное сообщество, за счет вознаграждения частью своей комиссии.\n  Как риэлтору выявить мотивацию собственника и задействовать в процессе продажи? Не всегда собственник, в самом деле, хочет или намеривается именно продать! При наличии объекта, клиент зачастую только «пробует попродавать» или «прощупывает» рынок на заинтересованность. Ведь это актив, за счет, которого он хочет решить свои вопросы – расширение жилплощади, разъезд, закрытие финансовых задач и т.д. Риэлтор может обезопасить себя от непредвиденных некорректных действий собственника, необъяснимого отказа от услуг или заморозке продажи – всего лишь договорившись о предоплате собственником на рекламу недвижимости.\n\nДетали и нюансы\nНе вкладывая денег в рекламу, как можно заработать эти самые деньги при продаже? :)\n  Весь потраченный бюджет вычитается из будущей комиссии риэлтора после продажи и подписания акта о проделанной работе.\n  Варианты предоплаты могут быть разными: передача средств риэлтору с последующим предоставлением чеков или оплата самим собственником счетов, по заранее указанным реквизитам.\n  Отчетность по растратам (чеки, счета), предоставляется вместе с отчетностью по звонкам, просмотрам – планово и за определенные периоды.\n  В предоплату не должно входить – размещение за бесплатные объявления, на сайте самих риелторов или агентств, выезд на просмотры и тому подобные варианты.\nПредоплата на рекламу никаким образом не приравнивается к предоставлению услуг или в качестве аванса не возвращается собственнику, так как все средства перечисляются конкретно на рекламу конкретного объекта.\n  Кто-то из собственников полностью оплачивает все самостоятельно, кто-то с посредниками пополам, кто-то только декларирует о растратах на рекламу, не придерживаясь договоренностям. Совет собственникам: контролируйте свои растраты риелторам.\n\nПодытожу:\n Предоплата, прежде всего, выгодна собственнику – за счет лучшего позиционирования объекта среди аналогов.\n  Клиент гарантировано получает положительный результат – сокращаются сроки продажи, выявляется спрос на его объект, продается по максимально-рыночной стоимости.\nПотраченные средства идут только на продвижение и рекламу объекта.\n  Весь бюджет высчитывается из будущей комиссии (фиксированной) и собственник в итоге не несет дополнительных материальных обязательств перед посредником.\nТолько от понимания собственником данного подхода и всех задействованных инструментов профессиональным посредником, зависит – какой в итоге будет результат.', 2, '2015-11-21 11:48:16', 'post_image-49.jpeg', 8),
(42, 'В чем разница между брокером, маклером и риелтором?', 'Объявления об услугах риелторов, брокеров и маклеров сейчас встречаются на каждом шагу; это востребованный бизнес, популярность которого с каждым годом только растет. С чем связана их деятельность? Как отличить одного посредника от другого и кому можно доверить свое имущество?\nВ чем заключается деятельность брокеров?\n\nУслуги брокеров востребованы среди тех, кто хочет получить гарантию на ту или иную сделку. \n\nБрокерами называют посредников между конкретным человеком или юрлицом и организацией, а оплачивается их работа процентами от суммы сделки, то есть комиссионными.\n\nБрокеры могут выполнять большой спектр услуг, а главный плюс в их работе – скорость, низкая стоимость и качество. Востребованы эти специалисты в финансовой и нефинансовой сфере. \n1. Это посредничество в денежной сфере (биржевые брокеры, финансовые аналитики и консалтинговые агентства). \n2. К деятельности нефинансовых брокеров обычно относят биржевых и таможенных специалистов, страховых брокеров, юридические фирмы, аналитические группы и так далее. \n\nБрокеры — это юридические лица, поскольку больше прав и возможностей. Физическое лицо брокером быть не может, поскольку гарантировать что-то, ему достаточно сложно, а работа под «честное слово», на уровне деловых переговоров или финансовой страховки, не устраивает заказчика. \n\nЧто касается договора, который заключается между брокером и его клиентом, то он будет содержать в себе следующие пункты: \n\n- cуть сделки (предмет); \n- стоимость самой услуги; \n- ответственность и права брокера и клиента; \n- сроки выполнения услуги; \n- банковские и юридические данные участников сделки. \n\nКто такие маклеры и можно ли им доверять?\n\nМаклер так же, как и брокер осуществляет посредническую деятельность, только с одной особенностью – он работает сам на себя. Уже исходя из этой информации, можно сделать вывод о том, что услуги маклера не совсем надежны, ведь этот человек не закреплен ни за одной организацией и может быть даже не оформлен как частный предприниматель (ЧП). Есть одна особенность, которая отличает маклера от брокера. Если брокер представляет интересы клиента, то маклер – это «сводник» для двух клиентов. Он помогает совершить сделку, находя двух партнеров, которым это выгодно, получая за это свой процент. \n\nМаклеры осуществляют схожую с брокерами деятельность: \n\n- посредник, заключающий сделки между покупателем и продавцом на валютной бирже; \n- консультант в сфере финансов, оценщик ценных бумаг; \n- страховой посредник; \n- посредник, занимающийся оформлением бумаг при купле-продаже жилья. \n\nЧтобы проверить законность работы посредника достаточно попросить у него документ, подтверждающий его право на оказание подобных услуг. \n\nЧем занимаются риелторы? \n\nРиелторы в отличие от брокеров и маклеров имеют более узкую направленность своей деятельности и занимаются только недвижимостью, поиском наиболее подходящих вариантов жилья для купли-продажи, аренды, строительства.\n\nДеятельность риелторов заключается в подборе для клиента наиболее безопасного, удобного и законного жилья. Причем весь процесс контролируется самим посредником, вплоть до хождения по квартирам или домам, вместе с клиентом. Заключение договора купли-продажи также находится под контролем риелтора, поэтому нарваться на мошенников в этом случае практически невозможно. Все переговоры между продавцом и клиентом агент берет на себя. \n\nВ чем разница между брокером, маклером и риелтором? \n\nОтвет на этот вопрос лежит прямо на поверхности. Маклер, единственный из посредников, чья деятельность не всегда подкреплена юридическими документами. Именно поэтому их услугами нужно пользоваться с особой осторожностью, внимательно читая все бумаги, которые вы подписываете при работе с этим агентом. \n\nБрокеры специализируются в основном в финансовой и таможенной сфере, а это значит, что по вопросам оценки, продажи и покупки ценных бумаг, а также судовладения и фрахтования нужно обращаться именно к ним. Работа брокеров – анализ рынка и прогнозирование цен на те или иные акции, а это значит, что эти посредники всегда в курсе информации и готовы предоставить консультации и спектр услуг в своей сфере деятельности. \n\nРиелторы – специалисты по недвижимости, способные решить любую проблему, связанную с жильем. \n\nБрокеры, маклеры и риелторы в целом ведут схожую деятельность, они посредники между двумя сторонами сделки, но каждый из них занимает свою нишу и получает доход от своих знаний в том или ином вопросе.', 2, '2015-11-25 21:01:33', 'post_image-50.jpeg', 80),
(43, '11 лучших городов для переезда', 'Все мы рано или поздно задумываемся о переезде в другой город или даже страну. Причин для этого может быть много: желание сменить обстановку, финансовые трудности, чувство небезопасности или мечта увидеть мир.\nОдна из крупнейших и известнейших консалтинговых компаний, составила список городов по всему миру, которые наиболее привлекательны для переезда. Оценил  Top-real.com.ua  их по таким критериям, как развитость инфраструктуры, здравоохранение, безопасность, экономическая ситуация и простота ведения бизнеса. Hermes Trismegistus выбрал 11 городов из верхушки этого списка и выделили особенности каждого из них.\nБерлин:\nПреимущества: общественный транспорт, безопасность. Все, кто когда-либо посещал Берлин, знают, что он имеет обширную сеть метро, которая отличается своей чистотой и удобством. Берлин также безопасен для туристов. Многие корпорации, такие как Google, SoundCloud и др., открывают все больше отделений в Берлине. Поэтому город часто называют европейской Кремниевой долиной. В прошлогоднем списке, Берлин занимал 16-е место, в этом же году он сместился на 12-е.\nЧикаго:\nПреимущества: качество жизни и воздуха. Чикаго – это один из самых больших городов США. Его население составляет 3 миллиона человек. В списке Top-real.com.ua Чикаго входит в первую десятку благодаря легкости ведения бизнеса, качеству жизни и воздуха. Однако не все так хорошо. Транспортная система и инфраструктура требуют серьезной доработки. Правительство Чикаго уже выделило несколько миллиардов на починку городского водопровода, школьных и муниципальных заведений. Но такие глобальные проекты требуют времени.\nСидней:\nПреимущества: климат, природа. Преимущества Сиднея очевидны. Мы все наслышаны об Австралии, ее замечательной природе, пляжах и фауне. В рейтинге Top-real.com.ua Сидней занял 1-е место по качеству жизни и благоустроенности. Что касается остальных показателей, таких как финансовая ситуация, инфраструктура и культура, Сидней также держится на высоте и практически не имеет слабых сторон. Единственный недостаток – это цены на жилье. Как и во всей Австралии, они весьма велики. К примеру, аренда однокомнатной квартиры в Сиднее будет стоить примерно $2000 в месяц. Ежедневные затраты в этом городе на 16% выше, чем в среднем по миру. Это ставит Сидней на 12-е место в списке самых дорогих городов в мире.\nГонконг:\nПреимущества: качество жизни, транспорт, низкие налоги на бизнес. Несмотря на невероятную плотность населения, Гонконг занимает 5-е место в мире по продолжительности жизни. Транспортная система Гонконга не вызывает нареканий — примерно 90% ежедневных передвижений совершаются на общественном транспорте. Гонконг занимает 1-е место по уровню экономической свободы благодаря низким налогам на бизнес и грамотно построенному финансовому рынку. Top-real.com.ua  поставил Гонконг на 2-е место за легкость ведения бизнеса. Недостатки Гонконга: загрязнение среды, качество воздуха.\nСтокгольм:\nПреимущества: содействие IT-сфере, чистота. Стокгольм – один из самых быстро развивающихся городов в Европе. Благодаря политике содействия IT-индустрии, в Стокгольме появились такие компании, как Spotify и DICE Games (выпустили Battlefield, Mirrors Edge и другие известные компьютерные и консольные игры). Улла Хамильтон, вице-мэр Стокгольма по инновациям , город старается всячески помогать IT-компаниям, так как именно за этой индустрией будущее. Стокгольм очень чистый и зеленый город. Развитая транспортная система, чистая вода и особая система отопления помогают поддерживать порядок. Единственным недостатком Стокгольма являются иммигранты, которых в последнее время становится все больше.\nПариж:\nПреимущества: образование, транспортная система. Париж славится своими библиотеками, университетами и высоким уровнем образования, занимая 1-е место в рейтинге самых образованных городов. Париж также знаменит своей транспортной системой. 14 веток метро, региональные поезда и отдельные полосы для автобусов – все это делает общественный транспорт Парижа на голову выше, чем в других городах. Из минусов можно выделить дорогое жилье, пробки и уровень безработицы, который немного превышает норму.\nСан-Франциско:\nПреимущества: IT-сфера, инновации. Треть всех инвестиций, которые приходят в США, получает Кремниевая долина, которая находится в Сан-Франциско. Это часть города, которая отличается большой концентрацией IT-корпораций. Google, Apple, Facebook, Microsoft, Adobe – это лишь небольшая часть компаний, офисы которых находятся здесь. Несмотря на то, что в рейтинге Top-real.com.ua  Сан-Франциско не самый дорогой город, с каждым годом он становится все дороже. Это заставляет многих переезжать в пригород.\nТоронто:\nПреимущества: уровень жизни, здравоохранение, инфраструктура, транспорт, безопасность. Несмотря на скандал с кокаино зависимым мэром, произошедший в 2012 году, Торонто является одним из самых лучших городов для проживания. Он находится в тройке лидеров по качеству жизни, безопасности и инфраструктуре, что делает его желанным городом дли переезда. В рейтинге общественного транспорта Торонто занимает 1-е место в мире. А в рейтинге загруженности дорог 13-е (чем выше позиция, тем хуже).\nСингапур:\nПреимущества: легкость ведения бизнеса, общественный транспорт. Сингапур имеет невероятную транспортную систему, основу которой составляют скоростные поезда. В своем отчете Top-real.com.ua отмечает, что с каждым годом Сингапур становится все лучше для жизни, постепенно исправляя все свои недостатки.\nНью-Йорк:\nПреимущества: устойчивая экономика, легкость ведения бизнеса, транспорт, инфраструктура. В списке Top-real.com.ua  Нью-Йорк является вторым желанным городом для переезда. Уверенную позицию Нью-Йорку обеспечили легкость ведения бизнеса, развитая транспортная система и замечательная инфраструктура города. По сравнению с другими городами, Нью-Йорк относительно дешев для проживания. но стоимость аренды жилья очень велика и уступает лишь двум городам в мире.\nЛондон:\nПреимущества: IT, легкость ведения бизнеса, транспорт. В рейтинге Top-real.com.ua  Лондон занял 1-е место, что делает его самым желанным городом для переезда. Правительство всячески способствует развитию бизнеса и IT-индустрии. Недавний проект Министерства связи обеспечил доступом в Интернет практически все лондонские школы. Транспортная система не вызывает нареканий. Всем известные двухэтажные автобусы ходят в соответствии с расписанием, указанным на остановках. А сверхбыстрый поезд может доставить вас в Париж за несколько часов. Лондон – один из самых богатых городов мира. Это одновременно и хорошо и плохо. К примеру, количество миллиардеров в Лондоне больше, чем в любом другом городе, что конечно же хорошо, но только для них. Многие жители жалуются на то, что город становится слишком дорогим даже для рабочего класса. Также стоит отметить большое количество иммигрантов, которые требуют у работодателя меньше денег, тем самым забирая работу у коренных жителей. Мне было бы интересно узнать, какое место в рейтинге заняли Москва, Киев и другие крупные города постсоветского пространства. Разумеется, что в первой тридцатке им делать нечего. К сожалению, у Top-real.com.ua  нет других исследований по этой теме.\n Но согласно исследованию Legatum Institute: Россия и Украина занимают 61-е и 64-е места соответственно в рейтинге уровня жизни, уступая таким странам, как Шри-Ланка, Мексика, Кувейт и Ямайка. Стоит заметить, что Legatum Institue – это независимая и некоммерческая организация, поэтому причин не верить им мы не видим.\"\"', 2, '2015-11-29 16:56:07', 'post_image-53.jpeg', 122),
(44, 'Как оформить квартиру в собственность', 'Вы приобрели квартиру и хотите побыстрее оформить право собственности, однако не знаете с чего начать? В этом нет ничего сложного. Главное, собрать полный пакет документов и знать в какие двери нужно постучать.\n\nПодготовка документов:\nПервое, о чем следует знать, это перечень документов, необходимых для регистрации. Список их можно найти в Порядок государственной регистрации прав на недвижимое имущество и их обременений, утвержденный Кабинетом министров Украины, постановлением № 868 от 17 октября 2013 года. Нужно собрать документы в полном объеме, если не будет хотя бы одного из них - Вам откажут в государственной регистрации.\n\nЭто основной перечень документов:\n- Заявление установленного образца;\n- Документ, удостоверяющий личность;\n- Правоустанавливающий документ на объект недвижимости;\n- Документ, подтверждающий наступления определенного события (например, заявление о расчете по договору купли-продажи, акт приема-передачи недвижимого имущества и т.д.);\n- Доверенность (если заявление подается представителем);\n- Квитанция или иной документ, подтверждающий оплату за предоставление выписок из государственного реестра прав;\n- Квитанция или другой документ, подтверждающий уплату админсбора;\n- Техпаспорт на квартиру;\n- Копии вышеперечисленных документов.\n\n2. Регистрация права собственности:\nЕе осуществляет Государственная регистрационная служба Украины и нотариус. То есть нотариус, может зарегистрировать право собственности за покупателем уже в момент заключения договора купли-продажи. Первичная регистрация находится не в его компетенции.\n\nПосле того, как все записи были внесены в госреестр, государственный регистратор формирует выписку из Госреестра прав и оформляет ее в двух экземплярах. Один остается у него, другой отдается на руки заявителю. Делается это, как правило, не более 5 рабочих дней. О стоимости этой процедуры можно узнать непосредственно у предоставляющих услуги.', 2, '2015-12-01 13:45:59', 'post_image-54.jpeg', 130),
(45, 'Як прискорити отримання витягу на земельну ділянку', 'Із питанням де і як отримати витяг із Державного земельного кадастру (ДЗК) про земельну ділянку стикається майже кожний громадянин, який бажає купити або продати земельну ділянку, подарувати її, передати в оренду тощо.\nСуть цієї адміністративної послуги регламентується Земельним кодексом України, Законом України «Про адміністративні послуги», Законом України «Про Державний земельний кадастр» та Порядком ведення Державного земельного кадастру, затвердженого постановою Кабінету Міністрів України від 17.10.2012 року № 1051.\n\nВідповідно до зазначених нормативно-правових актів ведення ДЗК здійснює Держземагентство та його територіальні органи.\n\nВитяг із Державного земельного кадастру про земельну ділянку містить усі відомості про земельну ділянку, внесені до Поземельної книги, а кадастровий план земельної ділянки є складовою частиною цього витягу.\n\nСтрок дії витягу із кадастру становить три місяці. Виняток встановлено лише для витягів, які видаються спадкоємцям та при реєстрації земельної ділянки в кадастрі – вони є безстроковими. Проте, речове право (право власності) на земельну ділянку має бути зареєстроване протягом одного року з дня отримання витягу про реєстрацію земельної ділянки в кадастрі.\n\n30 червня 2015 року Державна служба України з питань геодезії, картографії та кадастру та Державне агентство з питань електронного урядування України запустили електронну послугу «Замовлення витягу з Державного земельного кадастру». Це має спростити процедуру реєстрації земельної ділянки (надання ділянці кадастрового номера є частиною цієї процедури).\n\nДотепер замовлення витягу відбувалося лише за місцем безпосереднього розташування ділянки, що призводило до втрат часу та створювало корупційні ризики, оскільки етап подачі заяви та видачі результатів знаходився під контролем одного кадастрового реєстратора.\n\nТепер можливість замовлення послуги он-лайн скорочує процедуру оформлення до декількох хвилин, а розведення функції реєстрації заяви та її обробки зводить до мінімуму можливість зловживань.\n\nЗамовити витяг можна через Публічну кадастрову карту, яка розміщена на офіційному сайті Держгеокадастру. Простий та лаконічний інтерфейс робить послугу доступною навіть для невпевнених користувачів комп’ютерної системи. Підтвердження про сформовану заявку та повідомлення про готовність документу користувач отримує на свою електронну адресу.\n\nОтримати готовий витяг можна у будь-якому із центрів надання адміністративних послуг (ЦНАП) по всій Україні. Єдиний документ, який при цьому знадобиться, – посвідчення особи.\n\nЗа інформацією Урядового контактного центру з початку 2015року на урядову «гарячу лінію» надійшло понад 13 тисяч звернень щодо питань врегулювання земельних відносин. Громадяни, зокрема, цікавилися наданням земельної ділянки у користування, оформленням права власності на землю та оренду землі. Переважна більшість звернень надійшла від жителів Дніпропетровської, Київської та Одеської областей.\n\nНалагодження суспільного діалогу – важливий прерогатив державної політики. На жаль, ще не всі місцеві органи виконавчої влади належним чином використовують надані їм повноваження і можливості, тому громадяни, щоб бути почутими, вимушені звертатися до органів влади вищого рівня. Однією із форм такої взаємодії є звернення на урядову «гарячу лінію», що дає змогу заявникам оперативно отримувати достовірну інформацію від органів виконавчої влади.\n\nЗагалом за період з 30листопада по 6 грудня на урядову «гарячу лінію» надійшло 51 846 дзвінків, через Інтернет зареєстровано 715 звернень.\n\n0-800-507-309 – урядова «гаряча лінія» працює цілодобово.\n\n044-284-19-15 –для жителів м. Києва. +380-44-284-19-15 – для громадян, які перебувають за кордоном.\n\nВеб-сайт Урядового контактного центру www.ukc.gov.ua', 2, '2015-12-16 19:23:41', 'post_image-0.png', 218),
(46, 'Как правильно заключить договор пожизненного содержания', 'Из-за дороговизны квартир и плохо развитого банковского кредитования, городское жилье сейчас мало кому по карману. Решить проблему крыши над головой, может договор пожизненного содержания. Он заключается с пенсионером, готовым отдать вам квартиру после смерти при условии, что до этой самой смерти вы будете его материально обеспечивать. Как подписать договор правильно и избежать мошенничества со стороны пенсионеров. \n\nОЦЕНИВАЕМ ВЫГОДУ:\nПрежде чем подписывать договор пожизненного содержания, подумайте, насколько выгодны для вас его условия. Во-первых, узнайте у риелторов рыночную стоимость предлагаемой квартиры, ее расположение и нынешнее состояние. Во-вторых, сразу уточните, какой первоначальный платеж от вас требуется и какую сумму придется выплачивать ежемесячно. В-третьих, поинтересуйтесь возрастом и состоянием здоровья пенсионера. Прикинув, сколько он еще может прожить, посчитайте, во сколько вам обойдется эта квартира — возможно, овчинка не стоит выделки. По словам людей, заключавших подобные договоры с пенсионерами, они соглашались на сделку, если видели, что в целом квартира обойдется им в 30—40% от рыночной стоимости. Хотя у вас могут быть свои предпочтения. К сожалению, крепость здоровья старика можно оценить только «на глаз» — вы не имеете права потребовать у него пройти медосмотр.\n  А вот пригласить психиатра для осмотра можно и даже нужно. Он должен подтвердить, что пенсионер дееспособен, и выдать соответствующую справку.\n\nОФОРМЛЯЕМ ДОКУМЕНТЫ:\n У договора пожизненного содержания есть несколько обязательных условий, определенных в ст. 744—758 Гражданского кодекса Украины (ГКУ). Во-первых, там должно быть закреплено право хозяина квартиры жить в ней до смерти. Во-вторых, указана стоимость квартиры согласно договоренности. В-третьих, прописана сумма вашего первого платежа и размер ежемесячной помощи хозяину квартиры до самой его смерти в денежном выражении. Обычно там также указывается, что ежемесячная сумма должна ежегодно расти на размер официальной инфляции в стране. В-четвертых, в договоре нужно указать, что квартира не находится в залоге. И, наконец, прописать, что случайная утрата квартиры (пожар, разрушение и т. п.) не освобождает вас от необходимости выплачивать старику ежемесячное содержание.\n  Но в договоре могут присутствовать и другие пункты. Например, еженедельная уборка квартиры, оплата санаторно-курортного отдыха и др. Советуем вам не убирать квартиру самому, а воспользоваться услугами клининговой фирмы — тогда у вас на руках будут квитанции, подтверждающие оказание услуги.\n  К слову, такой договор всегда заключается в письменной форме. Его должен заверить нотариус и зарегистрировать БТИ. Иначе его признают недействительным. При этом за нотариальное удостоверение нужно заплатить гос.пошлину — 1% от стоимости квартиры. Услуги БТИ тоже платные.\n\nЗАЩИЩАЕМСЯ ОТ АФЕРИСТОВ:\nПенсионер, подписавший договор, всегда может изменить свое решение и потребовать его расторжения. Один из таких случаев недавно произошел в Киеве. В один из центров по социальной защите пенсионеров обратилась 86-летняя пенсионерка. Она попросила найти ей инвестора для заключения договора пожизненного содержания. «Все это время она очень часто общалась с работниками центра. — Есть записи всех ее телефонных звонков. Ей направляли сиделок и приносили необходимые продукты». В результате инвестора женщине нашли. Она подписала с ним договор, где была указана первая сумма проплаты в размере 40 тыс. грн и ежемесячное содержание — 800 грн. Но через некоторое время бабушка неожиданно написала жалобу в КГГА и заявление в прокуратуру. Она утверждала, что ее обманули и отняли квартиру мошенническим образом.\n  «Судья разжалобилась и стала на сторону бабушки. По решению суда договор признали недействительным. Хотя его заверяла государственный нотариус, которая тоже присутствовала на суде. Нотариус подтвердила, что бабушка была в полном сознании и трезвой памяти, и ее договор устраивал. На мой взгляд, давление на суд оказали телесюжеты об этой истории, которые транслировали несколько каналов, а также преклонный возраст бабушки. В результате она получила право не возвращать полученные ею деньги».\n  Обезопасить себя от таких судебных решений можно несколькими способами. Во-первых, нужно собирать все возможные доказательства того, что вы выполняли условия договора. Возьмите расписку о получении первой суммы, а потом выплачивайте ежемесячные платежи через банк, сохраняя квитанции. Во-вторых, процесс подписания договора лучше снимать на камеру. В-третьих, обязательно оформите договор в БТИ и Собесе (государственной социальной службе района). Ведь после того как пенсионер подписывает договор пожизненного содержания, Собес должен снять его с учета.\n\nНЕ ЗДРАВАЯ ПАМЯТЬ:\nСогласно ст. 746 ГКУ, передавать свою квартиру другому человеку по договору пожизненного содержания может любой гражданин, независимо от возраста, трудоспособности, состояния здоровья. Однако не забывайте, что здесь имеется в виду только физическое здоровье. К примеру, в судебной практике был случай, когда после смерти хозяина квартиры его родственник смог отсудить себе квартиру, а инвестор ничего не получил. В этом случае родственник принес в суд справки из психоневродиспансера о том, что бабушка, подписавшая договор пожизненного содержания, неоднократно проходила там лечение. И, подписывая договор, она вполне могла быть не в своем уме. Совет тут может быть только один: обязательно пригласите психиатра для оценки здоровья старика перед подписанием с ним договора.\n\nДВА ЖИЛЬЦА:\nПотерять квартиру, которую вы должны унаследовать, можете и в том случае, если будете ухаживать за двумя владельцами жилья, а договор подпишете только с одним из них. К примеру, это могут быть престарелые супруги. Ведь человек, завещавший вам свою долю в квартире, может умереть, а его супруг — расторгнуть подписанный договор. Чтобы избежать проблем, можно подписать договор с обоими собственниками квартиры. Или, если вы заключаете договор только с одним из них, заранее выделите его долю в общем имуществе в натуре. Впрочем, во втором случае у вас все равно могут возникнуть проблемы с выкупом оставшейся части квартиры у ее владельцев.\n\nРАННЯЯ СМЕРТЬ:\nВозможны и случаи, когда человек, который заботится о пенсионере (инвестор), умирает раньше хозяина квартиры. В этом случае право получить квартиру переходит к наследникам инвестора. Единственный способ забрать у них квартиру в таком случае — доказать, что они перестали исполнять условия договора. Если это произошло, их можно лишить права на жилье. Причем расходы умершего инвестора на содержание пенсионера не подлежат возврату, то есть оказываются потраченными впустую. ', 2, '2015-12-17 00:14:07', 'post_image-55.jpeg', 1),
(47, 'Четыре правила удачной сделки аренды квартиры', 'Правило № 1. Проверка и еще раз проверка. Следует обязательно убедиться, что все самые важные элементы жилья находятся в полном порядке. Это, в первую очередь, водопровод, газ, электричество и отопление. Для того, чтобы это проверить, достаточно внимательно осмотреть сантехнику, плиту, розетки и выключатели. Не стесняйтесь делать это при хозяине квартиры, ведь аренда жилой недвижимости – очень серьезный и ответственный  шаг, а также чаще всего является долгосрочным мероприятием. Открутите краны, слейте воду в туалете, проверьте наличие протечек. Эти нехитрые манипуляции часто помогают отсеивать неподходящие варианты в самом начале поиска съемного жилья. Осмотрите также окна, ведь сквозняки могут создать немало хлопот (можете воспользоваться зажигалкой или спичкой для проверки наличия щелей и сквозняков). Проверьте прочность входной двери и исправность замка. Вы также можете договориться с владельцем квартиры о замене замка, чтобы обезопасить себя от нежеланного проникновения бывших жильцов или соседей. \n\nПравило № 2. Окружение также очень важно Район, состояние дома и подъезда значительно влияют не только на размер арендной платы, но и на Вашу безопасность. Это могут быть и близко расположенные танцевальные клубы, создающие шум, или промышленные предприятия с отходным производством. Для многих окружение и вид из окна важны не менее внутренней обстановки квартиры, поэтому выбирать следует тот вариант, который подходит Вам по всем параметрам, включая и благополучность района. \n\nПравило № 3. Договор обязателен Если Вы хотите максимально обезопасить себя и уберечься от лишних хлопот и неприятностей, Вам стоит обязательно оформить отношения с владельцем квартиры при помощи договора аренды. Он не только защитит Ваши права, но и поможет избежать многих неприятных сюрпризов.\n\nПравило № 4. Требуйте документы у владельца Обязательно просмотрите весь пакет документов, который обязан предоставить арендодатель. В него входят как документы, удостоверяющие личность собственника, так и подтверждающие его права на владение и распоряжение недвижимым имуществом. Желательно также получить подтверждение согласия супруги/супруга владельца на сдачу недвижимости в аренду. Данный шаг поможет Вам избежать мошеннических действий.\n', 2, '2016-01-13 11:16:06', 'post_image-56.jpeg', 39);
INSERT INTO `posts` (`id`, `title`, `content`, `author_id`, `date`, `image`, `views`) VALUES
(48, 'Обязательства продавца и покупателя по договору купли-продажи', 'По договору купли-продажи продавец обязывается передать имущество в собственность покупателю, а покупатель обязывается принять имущество и оплатить за него определенную денежную сумму. (Часть вторая статьи 224 исключена на основании Закона N 107/94-ВР от 15.07.94) (Статья 224 с изменениями, внесенными согласно с Указом ПВР N 278-11 от 20.05.85, Законом N 107/94-ВР от 15.07.94).\n\nСтатья 225. Право продажи имущества.\nПраво продажи имущества, кроме случаев принудительной продажи, принадлежит владельцу. Если продавец имущества не является его владельцем, покупатель приобретает право собственности лишь в тех случаях, когда согласно со статьей 145 этого Кодекса владелец не вправе вытребовать от него имущество.\n\nСтатья 226. ( Статья 226 исключена на основании Закона N 3718-12 от 16.12.93 ) Договор купли-продажи обитаемого дома.\nОбитаемый дом (или часть его), что является личной собственностью гражданина или супругов, которые проживают совместно, и их несовершеннолетних детей, может быть предметом договора купли-продажи с сдерживанием статей 101 и 102 этого Кодекса, а также при условии, что от имени продавца, его жены и их несовершеннолетних детей не осуществлялось продаже больше как одного дома (или части его) в течение трех лет, за исключением продажи домов, приобретенных через брак или наследование. Отчуждение гражданином обитаемого дома более одного раза в течение трех лет допускается также при наличии уважительной причины из особенного в каждом разе разрешения исполнительного комитета районного, городского, районного в городе Совета народных депутатов. Если у гражданина или у жены, что вместе с ним проживает, и их несовершеннолетних детей есть в личной собственности обитаемый дом, купля им второго дома к прекращению права собственности на дом, что есть, допускается, когда это необходимо для удовлетворения потребностей семьи гражданина в жилье с разрешения исполнительного комитета районного, городского, районного в городе Совета народных депутатов. В случае купли второго дома первый дом подлежит отчуждению соответственно правилам статьи 103 этого Кодекса. Не может быть предметом договора купли-продажи нежилой обитаемый дом (или часть его), за исключением случаев продажи дома на снос, продажи части дома совладельцу, а также продажи дома для сезонного или временного проживания, если он расположен в сельской местности. При продаже обитаемого дома (или части его) не позволяется такое их дробление, при котором предметом договора купли-продажи является незначительная часть обитаемого дома (части дома), что не может быть выражен в виде отделенного обитаемого помещения, за исключением продажи ее совладельцу. Если обитаемый дом, что есть в личной собственности гражданина, подлежит снесению в связи с изъятием земельного участка для государственных или общественных потребностей, то этот дом может быть продан с разрешения исполнительного комитета районного, городского, районного в городе Совета народных депутатов, за исключением случаев продажи дома на снос или предприятиям, учреждениям, организациям, которым отведен земельный участок, а также продажи части дома совладельцу. (Статья 226 с изменениями, внесенными согласно с Указами ПВР N 278-11 от 20.05.85, N 6757-11 от 25.10.88).\n\nСтатья 227. Форма договора купли-продажи обитаемого дома.\nДоговор купли-продажи обитаемого дома должен быть нотариально удостоверен, если хотя бы одной из сторон является гражданин. Неисполнение этого требования тянет недействительность договора (статья 47 этого Кодекса). Договор купли-продажи обитаемого дома подлежит регистрации в исполнительном комитете местного Совета народных депутатов.\n\nСтатья 227-1. (Статья 226 исключена на основании Закона N 3718-12 от 16.12.93) Форма договора купли-продажи строительных материалов, что заключается между гражданами.\nДоговор купли-продажи строительных материалов, что заключается между гражданами, должен быть нотариально удостоверен, кроме случаев, когда продавец передает покупателю имущество вместе с документом о его приобретении в торговой или другой организации. Неисполнение этого требования тянет за собой применение правил, предусмотренных статьей 48 этого Кодекса.\n\nСтатья 228. Цена.\nПродажа имущества осуществляется по ценам, что устанавливаются по согласованию сторон, если другое не предусмотрено законодательными актами. (с изменениями, внесенными Законом N 3718-12 от 16.12.93).\n\nСтатья 229. Обязанность продавца предупредить покупателя о правах третьих лиц на продаваемую вещь.\nПри заключении договора продавец обязан предупредить покупателя обо всех правах третьих лиц на продаваемую вещь (право нанимателя, право закладной, пожизненного пользования и тому подобное). Невыполнение этого правила дает покупателю право требовать уменьшения цены или расторжения договора и возмещения убытков.\n\nСтатья 230. Обязанность продавца сохранять проданную вещь.\nЕсли право собственности (право оперативного управления) переходит к покупателю ранее передачи вещи (статья 128 этого Кодекса), продавец обязан к передаче сохранять вещь, не допуская ее ухудшения. Необходимые для этого расходы покупатель обязан возместить продавцу, если это предусмотрено договором (с изменениями, внесенными Указом ПВР N 278-11 от 20.05.85).\n\nСтатья 231. Последствия невыполнения продавцом обязанности передать вещь.\nЕсли продавец на нарушение договора не передает покупателю проданную вещь, покупатель вправе требовать передачи ему проданной вещи и возмещения убытков, нанесенных задержкой выполнения, или, из своей стороны отказаться от выполнения договора и требовать возмещения убытков.\n\nСтатья 232. Последствия отказа покупателя принять купленную вещь или оплатить ее.\nЕсли покупатель на нарушение договора откажется принять купленную вещь или заплатить за нее установленную цену, продавец вправе требовать принятия вещи покупателем и оплаты цены, а также возмещение убытков, нанесенных задержкой выполнения, или из своей стороны, отказаться от договора и требовать возмещения убытков.\n\nСтатья 233. Качество проданной вещи.\nКачество проданной вещи должно отвечать условиям договора, а при отсутствии указаний в договоре - требованиям, что обычно относятся. Вещь, что продается торговой организацией, должна отвечать стандарту, техническим условиям или образцам, установленным для вещей этого рода, если другое не выплывает из характера данного вида купли-продажи.\n\nСтатья 234. Права покупателя в случае продажи ему вещи неподобающего качества.\nПокупатель, которому продана вещь неподобающего качества, если ее недостатки не были предостережены продавцом, вправе за своим выбором требовать:\n- или замени вещи, определенной в договоре родовыми признаками, вещью надлежащего качества;\n- или соответствующего уменьшения покупательной цены;\n- или без оплатного устранения недостатков вещи продавцом или возмещение расходов покупателя на их исправление;\n- или расторжение договора с возмещением покупателю убытков;\n- или замены и такой же товар другой модели с соответствующим перечислением покупательной цены;\nПорядок реализации этих прав определяется Законом Украины \"О защите прав потребителей\" (1023-12) и другими актами законодательства. (С изменениями и дополнениями, внесенными согласно с Указом ПВР N 278-11 от 20.05.85, Законом N 107/94-ВР от 15.07.94 ).\n\nСтатья 234 -1. Право покупателя на обмен товара надлежащего качества.\nПокупатель в течение 14 дней, не считая дня купли, имеет право обменять непродовольственный товар надлежащего качества на аналогичный у продавца, у которого он был приобретен, если товар не подошел за формой, габаритами, фасоном, цветом размером или если по другим причинам он не может быть использован по назначению. Порядок осуществления такого обмена определяется Законом Украины \"О защите прав потребителей\". (1023-12). (Дополнено статьей соответственно Закону N 107/94-ВР от 15.07.94).\n\nСтатья 235. Сроки предъявления претензий в связи с недостатками проданной вещи.\nПокупатель вправе заявить продавцу претензию по поводу не предостереженных продавцом недостатков проданной вещи, на которую не установлен гарантийный срок, если недостатки были выявлены в течение шести месяцев со дня передачи относительно недвижимого имущества – не позже трех лет со дня передачи их покупателю, а если день передачи недвижимого имущества установить невозможно или если имущество находилось у покупателя к заключению договора купли-продажи - со дня заключения договора купли-продажи. (В редакции Закона N 107/94-ВР от 15.07.94).\n\nСтатья 236. Претензии по поводу недостатков вещи, проданной с гарантийным сроком.\nВ случаях, когда для вещей, что продаются через розничные торговые организации, установлены соответственно статье 250 этого Кодекса гарантийные сроки, эти сроки вычисляются со дня розничной продажи. Покупатель в течение гарантийного срока может представить продавцу претензию по поводу недостатков проданной вещи, что препятствуют ее нормальному использованию. (Часть вторая статьи исключена соответственно Закону N 107/94-ВР от 15.07.94) (Статья 236 с изменениями, внесенными согласно с Законом N 107/94-ВР от 15.07.94).\n\nСтатья 237. Срок давности за иском о недостатках проданной вещи.\nИск по поводу недостатков проданной вещи может быть предъявлен не позже шести месяцев со дня отклонения претензии, а если претензия не заявлена или день ее заявления установить невозможно - не позже шести месяцев со дня окончания срока установленного для заявления претензии (статьи 235, 236 этого Кодекса).\n\nСтатья 238. Ответственность продавца за отсуживание проданной вещи у покупателя.\nЕсли третье лицо на основании, что возникло к продаже вещи, предъявит к покупателю иск о ее отобрании, покупатель обязан притянуть продавца к участию в деле, а продавец обязан вступить в это дело на стороне покупателя. Не притягивание покупателем продавца к участию в деле, освобождает продавца от ответственности перед покупателем, когда продавец доведет, что, приняв участие в деле, он мог бы предотвратить изъятие вещи у покупателя. Продавец, который был притянут покупателем к участию в деле, но не принял в ней участие, лишается права доводить неправильность ведения дела покупателем.\n\nСтатья 239. Обязанность продавца в случае отсуживания проданной вещи.\nЕсли в силу решения суда, арбитража или третейского суда проданная вещь изъята у покупателя, продавец обязан возместить покупателю понесенные им убытки. Соглашение сторон об освобождении или ограничении ответственности продавца недействительно, если продавец, зная о существовании прав третьей личности на продаваемую вещь, преднамеренно скрыл это от покупателя.\n\nСтатья 240. Продажа товаров в кредит.\nТовары длительного пользования могут продаваться гражданам розничными торговыми предприятиями в кредит (с рассрочкой платежа) в случаях и порядке, устанавливаемом законодательством Союза ССР и Украинской ССР. Продажа товаров в кредит осуществляется по ценам, что действуют на день продажи. Следующее изменение цен на проданные в кредит товары не тянет за собой пересчета. Право собственности на товары, что продаются в кредит, возникает у покупателя соответственно правилам статьи 128 этого Кодекса. (с изменениями, внесенными Указом ПВР N 278-11 от 20.05.85).', 2, '2016-01-16 19:16:19', 'post_image-57.jpeg', 111),
(49, 'Основное о новых правилах регистрации недвижимости', 'Напомним основные моменты нового порядка, который должен знать каждый владелец недвижимости. Так, по новым правилам, свидетельство о праве на недвижимость выдаваться не будет, а оформить его можно только в электронном виде.\nПри этом, теперь право на недвижимость будет подтверждаться через интернет. А регистрацию недвижимости можно будет проводить у нотариусов без ограничений. Факт владения имуществом будет подтверждаться решением, оформленным в электронном виде. На руки владелец может получить распечатку этого решения, но на нее не ставится ни подпись, ни печать регистратора.\nВ то же время, как отмечают некоторые эксперты, такое нововведение может вызвать недоверие у людей пожилого возраста, когда их право на квартиру подтверждается обычной распечаткой. Кроме того, некоторые опасаются, что в связи с тем, что теперь не будет \"документа с синей печатью\", может быть всплеск рейдерских атак на недвижимость. Поэтому владельцам советуют периодически проверять свои объекты собственности в реестре, доступ к которому может получить каждый зарегистрированный.', 2, '2016-01-18 20:08:35', 'post_image-58.jpeg', 98),
(50, 'Как успешно найти жилье в Польше', 'Каждому, кто приезжает в новый город, сначала приходится думать о поиске жилья. Этот процесс неразрывно связан с опасностью быть обманутым нечестными посредниками или владельцами. Те, кто переезжает в новую страну, автоматически сталкиваются с рядом дополнительных проблем. О них мы и поговорим.\n1. Ищите жилье только на специализированных порталах. В Польше для этой цели самыми популярными страницами является olx.pl, Gumtree.pl, otodom.pl. Здесь найдете цену и фото квартиры, а также контакты к владельцу. На портале существует возможность отфильтровать не только город, ценовой диапазон и район, но также просматривать объявления непосредственно от владельцев.\n2. Используйте Фейсбук. В современном мире социальные сети - не только поглотители времени, но и замечательные инструменты, которые нужно научиться использовать. Попробуйте создать привлекательный пост, где описываете себя и все свои потребности в жилье, а еще лучше - сделайте это объявление визуальным и цветным, чтобы бросалось в глаза. Сейчас это не требует больших усилий, все быстро делается в одном из множества соответствующих мобильных приложений. Чем интереснее объявления - тем больше будет его распространений, что автоматически увеличивает Ваши шансы. Этот пост можно и нужно разместить на Фейсбук-страницах, созданных специально для поиска жилья. Важно: если ищете квартиру в Польше - писать польской, это значительно расширит аудиторию.\n3. Будьте осторожны, когда сотрудничаете с посредниками и агентствами. Хотя жилье вполне возможно найти самостоятельно, много Украинский обращается за помощью агентств недвижимости. Это кажется хорошим выходом, если не говоришь польской и не имеешь знакомых, которые могли бы помочь, но очень часто Украинцы становятся жертвами мошенников. Так, возникает множество агентств-однодневок, которые принимают деньги за посредничество и исчезают на следующий день; или предлагают квартиры в ужасном состоянии или за слишком высокую цену. Поэтому работайте с агентствами, которые на рынке давно. Важно: никогда не платите за возможность увидеть квартиру. Если посредник просит заплатить, потому что только тогда он покажет квартиру, - это мошенник.\n4. Уточняйте цену и спрашивайте о «скрытых» оплаты. Если Вам предлагают «кавалерку» (маленькую комнатку с кухней) за 1000 злотых в центре города - не радуйтесь раньше времени, а тщательно проверьте дополнительные оплаты, которые могут неожиданно появиться: коммунальные услуги, Интернет, а главное т.н. «Оброк» - ежемесячная оплата для сообщества жителей на содержание дома и придомовой территории. Иногда она может составлять половину той суммы, которую просит владелец. Если же добавить все составляющие - значит ежемесячная сумма до 2000 злотых. Немало.\n5. Подписывать договор. Подписанный договор - это документ, дающий вам право официально проживать в квартире. В случае каких-либо недоразумений с владельцем это еще и единственный документ, дающий право доказать правоту. Подписанный договор - это гарантия не являться выброшенным на улицу без объяснений. Кроме того, копия условия найма необходима для оформления карт пребывания, ее тоже требуют, если надумаете пригласить в гости родственников.\n6. Помните о «кауцию». Это - залог в размере месячной оплаты, которую владельцы берут в качестве гарантии того, что помещение останется в таком же состоянии, как и в начале найма, а также в качестве гарантии оплаты нанимателем всех счетов. Залог обычно учитывается при подписаны условия, но может быть разделена на меньшие суммы в течение первых месяцев, если об этом договоритесь с владельцем. При выселении залог возвращается или Вы просто не платите за последний месяц проживания. Важно уточнять, что «кауцию» будет возвращен, а также проследить, что этот пункт был включен в условия. Планируйте свой бюджет заранее и цену квартиры умножайте на два - именно такая сумма необходима для начала.\n7. Обсудите способ оплаты за коммунальные услуги. Есть две возможности: либо Вы платите сами, согласно платежами, или же это делает владелец. Он предложит два способа: среднюю сумму ежемесячно или оплату по счетчикам. Первый способ хорош тем, что в течение года платите одинаковую сумму, поэтому не зависите от отопительного сезона. Второй способ хорош для тех, кто умеет экономить.\n8. Уточните, есть ли в квартире подключения к Интернету. Как ни странно, аренда помещения с действующим Интернетом в Польше - это скорее исключение, чем правило. Если в объявлении не написано о наличии Интернет-подключения, то его там скорее и нет. Спросите сразу, чтобы это не стало неожиданностью.\n9. Познакомьтесь с соседями. Это не только даст возможность получить нужную информацию, оставить в них ключи или попросить накормить кота, но и обеспечит «видимость» и свидетельство в Вашу пользу в случае конфликта с владельцем.\n10. Помните, что Вы платите деньги, а значит, есть определенные права. Так, любые проблемы, возникающие в квартире (неисправна проводка, сантехника и т.д.) должен решать ее владелец, а не Вы. Он платит за ремонт холодильника или стиральной машинки, если они испортились не по Вашей вине, а также оплачивает дополнительные сборы сообщества жителей. Кроме того, каждый человек, независимо от страны происхождения и правового статуса, имеет право вызвать полицию и обратиться в суд, если квартиросъемщик то образом нарушает его права.\nБудьте бдительны и удачных поисков! Александр Ткаченко top-real.com.ua\nВидео по здесь: https://www.youtube.com/user/SuperSanches007', 2, '2016-01-25 15:07:12', 'post_image-59.jpeg', 81),
(51, 'Как не платить новый налог на недвижимость!', 'Как можно НЕ платить новый налог на недвижимость. Немного хлопотно, но вполне законно.\nЛично я бы пошёл на это даже не из-за экономии на налогах, а из принципа: безмозглое правительство должно быть изящно наказано за свою жадность!\nИтак, если вам НЕ повезло)) и вы являетесь владельцем нескольких квартир / домов, общая площадь которых превышает 180 м2 (льготная суммарная площадь, не облагаемая налогом на недвижимость), помните, что граничный \"порог\" налогообложения может поднять ЛЮБОЙ сельсовет на территории Украины (п. 266.4.1 Налогового кодекса Украины)!\n\nНапример, у вас есть квартира в Киеве в 200 м2 и загородный дом в 400 м2. И за это счастье вы должны будете уплатить около 10 000 грн налога ((200+400-180) * 2% от минимальной заработной платы). Само собой разумеется, эти 10 000 грн улетят в пустоту ( = \"бюджет\").\n\nВыход есть: вы находите и покупаете хату в самом забитом украинском селе (а еще лучше, покупаете её вскладчину с несколькими друзьями; а если есть сто друзей - так это просто здорово, выйдет по 0,5 кв. м на каждого!). В итоге, суммарная площадь вашей недвижимости станет чуть больше, скажем, на 20 м2 (200+400+20).\n\nНо зато по закону сельсовет этого забитого украинского села может поднять для вас (с друзьями) предельную норму не облагаемой налогом недвижимости до, например, 1 000 м2 (напоминаю: п. 266.4.1 Налогового кодекса Украины). Таким образом, вы со своими 620 м2 под налогообложение вообще не попадаете!\n\nВы, конечно, должны будете \"инвестировать\" в забитое украинское село пару тысяч гривен, но, уверен, сделаете это с радостью, поскольку государство не даёт этому селу вообще ни копейки.\n\nСхема верная (если, конечно, читать обновлённый Налоговый кодекс буквально).', 2, '2016-02-03 19:09:38', 'post_image-60.jpeg', 117),
(52, 'Пошаговая инструкция госрегистрации прав на недвижимое имущество по новым правилам', 'Согласно новой редакции закона, государственная регистрация прав проводится по заявлению заявителя, после чего нотариус (или его помощник – далее везде по тексту) формирует и распечатывает заявление в двух экземплярах, на которых заявитель и нотариус проставляют свои подписи. Один экземпляр заявления предоставляется заявителю, а второй приобщается к документам, представленных для государственной регистрации прав.\n\nПосле проставления подписей в заявлении нотариус регистрирует заявление в базе данных. Моментом принятия заявления считается дата и время его регистрации в базе данных заявлений.\n\nВместе с заявлением заявитель подает оригиналы документов, необходимых для соответствующей регистрации, и документы, подтверждающие оплату административного сбора и/или внесения платы за предоставление информации из Государственного реестра прав, в случае, если заявитель не освобожден от оплаты таких платежей.\n\nИз представленных оригиналов документов, необходимых для государственной регистрации прав, нотариус изготавливает электронные копии. По результатам рассмотрения заявления и документов, представленных для государственной регистрации прав, нотариус и регистратор принимает решение о регистрации прав или об отказе.\n\nЗатем нотариус вносит соответствующие записи в Государственный реестр вещных прав на недвижимое имущество, а после формирует информацию из него.\n\nИнформация из Государственного реестра прав по желанию заявителя может быть предоставлена в бумажной форме без использования специальных бланков, проставления подписи и печати нотариуса.\n\nВсе документы также хранятся в электронной форме в этом Реестре.\n\nИнформация из Государственного реестра прав в бумажной или электронной форме имеет юридическую силу и содержит обязательную ссылку на Государственный реестр прав.\n\nВместе с тем выдача любых документов государственным регистратором в бумажной форме на вновь созданное имущество - не предусмотрено действующим законодательством. Зарегистрированное право собственности можно проверить на Госреестре.\n', 2, '2016-02-09 16:42:02', 'post_image-61.jpeg', 118),
(53, 'Алгоритм реєстрації права власності на нерухоме майно в 2016 році', 'У 2016 році замість свідоцтва про право власності видається інформаційна довідка. Проте, власникам житла важко розібратися у новому порядку реєстрації. Колеги, сьогодні, після посвідчення декількох договорів відчуження нерухомого майна, написал для себе конспект короткого алгоритму дій по реєстрації прав, може він допоможе комусь із Вас, хто ще не здійснював реєстраційні дії у цьому році!\n\n25 грудня 2015 року Кабінетом Міністрів України було прийнято Постанову №1127 «Про державну реєстрацію речових прав на нерухоме майно та їх обтяжень», якою затверджений Порядок державної реєстрації речових прав на нерухоме майно та їх обтяжень, Порядок надання інформації з Державного реєстру речових прав на нерухоме майно та Порядок доступу до Державного реєстру речових прав на нерухоме майно, яким встановлений наступний порядок дій:\n\nП. 7 вищевказаного Порядку державної реєстрації речових прав зазначає, що спочатку нотаріус або його помічник за допомогою програмних засобів ведення Державного реєстру прав (виходячи з останнього роз’яснення ДП «НАІС» від 12.01.2016 р ми робимо це у UB):\n\n1) формує та роздруковує заяву у двох примірниках, на яких проставляються підписи заявника та нотаріуса або його помічника. Один примірник видається заявникові, а другий долучається до поданого пакету документів;\n\n2) реєструє заяву у базі даних заяв (як говорить практика технічно на сьогоднішній день немає можливості роздрукувати заяву без її реєстрації в базі даних, тому реєстрація та роздрукування відбувається одночасно);\n\nЗгідно з п. 8 та п. 9 вищевказаного Порядку нотаріус або його помічник:\n\n3) Перевіряє подані заявником документи, встановлює його особу, обсяг повноважень, сплату адмінзбору і т.д.;\n\nЗгідно з п. 10 вищевказаного Порядку нотаріус або його помічник;\n\n4) виготовляє електронні копії з поданих заявником оригіналів документів шляхом сканування, які долучаються до заяви (сканування через UB дуже складне та незручне, порада зменшувати об\'єм файлу шляхом переведення у формат .*jpeg);\n\nЗгідно з п. 12 вищевказаного Порядку нотаріус:\n\n5) здійснює пошук заяв у базі даних заяв та встановлює черговість заяв, здійснює пошуки за об\'єктом та за суб\'єктом;\n\nЗгідно з п. 18 вищевказаного Порядку нотаріус:\n\n6) за результатом розгляду заяви та документів приймає рішення щодо державної реєстрації прав або щодо відмови в такій реєстрації;\n\nЗгідно з п. 19 вищевказаного Порядку нотаріус:\n\n7) відкриває та/або закриває розділи в Державному реєстрі прав, вносить до відкритого розділу або спеціального розділу відповідні відомості про речові права та їх обтяження, про об‘єкти та суб‘єкти цих прав;\n\nЗгідно з п. 22 вищевказаного Порядку нотаріус:\n\n8) формує інформацію з реєстру, яка розміщується на веб-порталі Мін‘юсту (це відбувається автоматично тільки за умови роботи в UB);\n\n9) на бажання заявника надає йому інформацію у паперовій формі на аркуші формату А4 без використання бланків, проставлення підпису та печатки нотаріуса (на практиці технічні можливості реєстру на сьогоднішній день дозволяють видати інформацію у вигляді витягу або інформаційної довідки, наші контролюючі органи рекомендують інформ. довідку)».', 2, '2016-02-13 22:32:37', 'post_image-1.png', 59),
(54, 'Наследство: совет юриста!', 'Основные правила:\nПроцедура вступления в наследство не так проста, как может показаться. Порядок строго регламентирован Гражданским кодексом Украины (ГКУ), в частности статьями 1222, 1223, 1296, 1297, и рядом других актов. А незнание законов и процедур, как известно, не снимает с граждан ответственности за их нарушение. Чтобы процесс не превратился в бюрократический или моральный кошмар, надо четко понимать необходимые шаги, их содержание и очередность.\n\n Наследование – это переход прав и обязанностей от умершего физического лица к другим лицам (иначе говоря, наследникам). Принять на себя можно все права и обязанности, которые ранее принадлежали умершему лицу и не были прекращены с момента его смерти.\n Наследование бывает двух видов. Первый и очевидный – по завещанию. Если оно не было составлено, то имущество можно наследовать вторым способом – по закону. Оформление документов в обоих случаях аналогично. Процедура наследования начинается при смерти владельца недвижимости (о чем есть подтверждающие документы) или признании его официально умершим (согласно решению суда).\n Завещание – это личное распоряжение физического лица (наследодателя) на случай собственной смерти. Завещатель может как назначить своими наследниками одного или нескольких человек, так и лишить их права на наследство. Наличие родственных или семейных отношений в данном случае не имеет значения.\n Наследование по закону происходит в порядке очереди. Сначала имущество переходит к наследникам первой очереди, к которым относят ближайших родственников умершего – мужа/жену, детей и родителей. Если таковые отсутствуют, подключается вторая очередь – братья и сестры, бабушки и дедушки с обеих сторон. Нет и их – право на наследство имеют родные дяди и тети, после которых следует лицо, проживавшие с наследодателем в гражданском браке не менее пяти лет до времени открытия наследства. В последнюю очередь принять собственность могут любые родственники наследодателя до шестой степени родства включительно. При этом преимущественное право имеют более близкие родственники в зависимости от числа родственных связей, которые отдаляют родственника от наследодателя.\n Доли каждого наследника в наследстве являются равными, если наследодатель в завещании сам не распределил наследство между ними. Вне зависимости от содержания завещания, несовершеннолетние дети и нетрудоспособные ближайшие родственники (вдова/вдовец, родители, совершеннолетние дети) получают половину той доли, которая могла бы причитаться им по закону. А на выделение в натуре при разделении имущества предметов домашнего обихода преимущественное право имеют лица, которые не менее одного года до времени открытия наследства проживали вместе с умершим лицом в одном жилище.\n Наследник по завещанию или по закону имеет право принять наследство или не принять его. В то же время не допускается принятие наследства с условием или с оговоркой. Вступить можно во владение всем перечнем прав, принадлежавшим наследодателю, без исключений. А кроме того, придется взять на себя все обязанности и обременения, в том числе долговые и кредитные.\n\nОсобые условия завещания:\nГКУ дает возможность составить завещание так, чтобы обязать наследников выполнить определенные условия для получения наследства. Требуется либо выполнение этих условий на момент смерти завещателя, либо уже после открытия наследства. Например, наследодатель может указать, что завещает свой дом сыну, но при условии, что он продолжить жить в родном городе и в течение пяти лет заведет детей. Кроме того, супруги могут написать общее завещание относительно совместного имущества. Надо только понимать: в случае смерти одного из супругов второй не может изменить общую волю.\n\nИзменения в очереди:\nОчередность получения наследниками по закону права на наследование может быть изменена нотариально удостоверенным договором заинтересованных наследников, заключенным после открытия наследства. Этот договор не может нарушить прав наследника, который не принимает в нем участия, а также наследника, имеющего право на обязательную долю в наследстве. Например, контракт могут между собой заключить двое братьев из трех. Но если третий не принимает участие в договоре, то его доля не может быть изменена или оспорена.\n\nЕсли время прошло:\nЕсли пропущен шестимесячный срок со дня смерти наследодателя (или признания его таковым по суду), есть возможность попытаться стать обладателем наследственного имущества в судебном порядке. Сделать это будет нелегко. Судья потребует предъявить неопровержимые доказательства того, что имеется право на наследство. Кроме того, придется объяснить, почему в течение полугода не принимались попытки вступить в наследство или о таком праве не было известно. На принятие положительного решения влияет наличие таких обстоятельств, как продолжительная болезнь, длительное отсутствие в регионе или стране. Причем сначала надо обратиться к государственному нотариусу по месту регистрации оспариваемой недвижимости и получить там документальный отказ в праве на вступление в наследство. После этого можно идти в суд.\n\nПорядок действий:\nПервое, что необходимо сделать наследникам, – обратиться к государственному нотариусу по месту последнего проживания умершего и написать заявление о принятии наследства. В главе 10 раздела II Порядка совершения нотариальных действий нотариусами Украины, утвержденного приказом Министерства юстиции Украины от 22 февраля 2012 года № 296/5, определено, что место открытия наследства подтверждается справкой жилищно-эксплуатационной организации, адресного бюро или военкомата. Если точных данных о месте жительства нет, местом открытия наследства считают местонахождение недвижимого имущества или основной его части.\n Сделать это нужно как можно быстрее, в срок не более шести месяцев. Заявление за нетрудоспособных или несовершеннолетних пишут родители или официальные опекуны. Наследник по завещанию или по закону может отказаться от принятия наследства в течение шести месяцев. Заявление об отказе от принятия наследства подается нотариусу по месту открытия наследства. В таком случае доля переходит к другим наследникам по завещанию и распределяется между ними поровну. Правда, в отказе можно указать переход своей доли в пользу другого лица. Наконец, если потенциальный наследник пропустил срок подачи заявления, то он будет считаться лицом, которое не приняло наследство.\n К нотариусу следует идти с определенным набором документов. К нему относят свидетельство о смерти завещателя (оригинал + копия), выписку из домовой книги, справку с последнего места жительства наследодателя. Также берут свой паспорт и все правоустанавливающие документы на наследуемое имущество. Это, в частности, может быть договор дарения и купли-продажи, выписка из Госреестра о наличии права собственности и т. д. Если в наследство вступают по закону, дополнительно предоставляют все, что может подтвердить родство с умершим. Это, например, может быть свидетельство о рождении или заключении брака.\n Нотариус выдает свидетельство о праве на наследство на недвижимое имущество. Далее наследник обязан зарегистрировать свое право на владение недвижимым имуществом в Госреестре. С момента государственной регистрации этого имущества у наследника возникает непосредственноправо собственности.\n В конце этих действий наследник (или каждый из них) получает на руки правоустанавливающий документ, в котором подтверждается его право на владение имуществом (при наличии нескольких наследников в документе указывают долю каждого). С этого момента наследник становится полноправным собственником (совладельцем) дома.\n\nКак быть с землей?\nВ общем случае процедура наследования земельных участков практически не отличается от процесса получения дома в наследство. Однако если нет завещания, то для вступления в наследство по закону придется найти и предоставить дополнительные документы. Это, в частности, правоустанавливающие документы на земельный участок. Например, свидетельство о пожизненном праве собственности на землю, договоры дарения, купли-продажи, ренты или мены. Кроме того, в местном отделении Госреестра надо взять кадастровый паспорт на земельный участок с указанием в нем его кадастровой стоимости на день смерти завещателя. Еще берут справку, подтверждающую отсутствие обременений на землю. Таковыми могут быть наложение ареста или внесение в залог кредита. Наконец, добавляют справку об оценочной стоимости земельного участка, согласно которой определяют размер государственной пошлины для проведения регистрации. Этот документ получают в любой независимой оценочной организации.\n Следует понимать: если на момент смерти владельца участка земля не была правильно зарегистрирована и не имела кадастрового номера, то наследнику (наследникам) придется пройти этот путь самостоятельно. Чтобы не получить отказ (ведь юридически право наследования еще не вступило в силу) и не потратить деньги на процедуру зря, лучше сразу попросить нотариуса самостоятельно подать официальный запрос в государственную службу кадастра и получить этот документ.\n Немалую сложность представляет собой разделение земли на части между всеми наследниками. В тех случаях, когда размер и характеристики позволяют, участок делят между всеми наследниками в равных долях. Но нередко делить практически нечего. В таком случае решить вопрос можно посредством заключения договора с другими наследниками, выплаты им финансовой или иной компенсации и т. д. Все неурегулированные претензии решают в судебном порядке.\n\nПо совместному согласию:\nЕсли умерший оставил после себя не только дом и участок, но и другое существенное имущество (например автомобиль, депозит в банке или долю акций в предприятии), об их распределении можно договориться друг с другом и закрепить решение документально. Или, как и в других случаях, обратиться в суд с иском об оспаривании права собственности.\n\nСтоимость оформления:\nСогласно нормам Декрета Кабинета министров Украины «О государственной пошлине», за выдачу свидетельства о праве на наследство взимают пошлину в размере двух необлагаемых налогом минимумов доходов граждан, то есть 34 грн на данный момент. За регистрацию права собственности взимают семь необлагаемых минимумов, или 119 грн. За проверку информации о наличии или отсутствии заведенного наследственного дела и выданных свидетельств о праве на наследство с предоставлением выписки или информационной справки по данным Наследственного реестра, формирование в Наследственном реестре регистрационной записи о выдаче свидетельства о праве на наследство пошлина составляет три необлагаемых минимума, или 51 грн.\n\nКроме того, принятие наследства дает возможность существенно увеличить свои активы. Поэтому неудивительно, что унаследованное имущество облагается подоходным налогом. Согласно нормам Закона Украины «О налогообложении доходов физических лиц», наследственным имуществом, подлежащим налогообложению, являются недвижимость, транспортные средства, предметы антиквариата, суммы страхового возмещения, вклады в банках и др. Ответственность за перечисление суммы налога на наследство в бюджет несут сами наследники. Нотариус, выдавший свидетельство о праве на наследство, не является налоговым агентом и обязан лишь проинформировать налоговые органы о факте выдачи свидетельства. Уплата налога на наследство производится плательщиком на основании платежного извещения, которое вручается ему в налоговом ведомстве. Оплатить налог надо в срок не более трех месяцев со дня вручения уведомления.\n В то же время ставка налога для родственников первой степени (вдовы или вдовца, детей и усыновленных детей) составляет 0 %. Таким образом, данные наследники лишены необходимости платить подоходный налог. Все иные наследники платят 5 % от суммы экспертной стоимости имущества. А если произошло вступление в наследство, расположенное на территории Украины, но от наследодателя- нерезидентом, то налог рассчитывают по ставке 15 % вне зависимости от степени родства. Следует понимать, что нерезидентном считается всякое лицо ( независимо от гражданства), которое проживает на территории Украины менее 183 дней в течение года.\n Следует понимать, что штраф за несвоевременную уплату налога на наследство при задержке до 30 дней составляет 10 % от суммы долга, на срок до 90 дней – 20 %, более 90 дней – 50 %.', 2, '2016-02-23 23:11:19', 'post_image-62.jpeg', 265),
(55, 'Умный дом - это новая эра', 'Приход весны активизирует работы подрядчиков по установке систем «умного дома». Несмотря на вызванное кризисом существенное проседание спроса на услуги по инсталляции систем «умного дома», весной участники рынка ожидают оживление. Одновременно со строительными работами инсталляторы приступают к установке необходимых умных систем.\n\nИмпортный рынок!\nЗа последние пару лет рынок просел сильно. Если в 2012 году люди обращались для проведения просчетов стоимости 2-3 раза в месяц, то сейчас – раз в 2-3 месяца. И то, в основном на этапе составления сметы все и заканчивается.\nОбъясняется такая ситуация просто. Практически весь рынок состоит из импортного оборудования и ПО, поэтому накрепко привязан к валюте. «На рынке уже несколько лет существует мировом тенденция к снижению цен, ведь производителей становится больше, обороты их увеличиваются, но из-за падения гривны нам это снижение цен незаметно».\nОсновные поставщики систем – Китай, Европа и США. Европейский товар, на 25-30% дороже китайского, американский – вдвое. Впрочем, говорят эксперты, цена товара и регион производства влияют прежде всего на дизайн и функционал. Любимое сравнение – с автомобилями: все автомобили справляются с главной функцией – ездой, а уровень комфорта, надежности и долговечности покупатель определяет, исходя из толщины своего кошелька.\n\nНемногочисленные украинские стартапы пока только осторожно прощупывают рынок. Например, летом 2015 года фонд SMRK вложил $1 млн в украинскую компанию Ajax Systems, занимающуюся разработкой и производством охранных систем и датчиков для «умного дома». Украинцы обещают более чем приемлемые цены – на порядок ниже, чем за импортный товар. Но в Америке и в Европе, говорят эксперты, этими технологиями занимаются уже десятки лет, поэтому зарубежные производители готовы предоставлять комплексные и гибкие решения.\n\nДорого и оправданно?\nИнсталляторы систем «умного дома» неохотно говорят о стоимости своей продукции и услуг, объясняя, что все очень индивидуально, зависит от проекта и пожеланий заказчика. Но ориентировочные ценовые параметры определить можно. Например, трехкомнатная квартира площадью около 80 кв. м обойдется примерно в €12 тыс.. В эту сумму входит полный комплект таких функций как управление светом, вентиляцией, отоплением, базовой безопасностью, телевизором.\n\nПо словам эксперта, только качественное управление освещением в 2-3-комнатной квартире обойдется в €2-3 тыс. Панели управления, которые размещаются в каждой комнате, обходятся примерно по €250. Увеличить бюджет может, например, желание заказчика управлять своим жильем удаленно, из-за пределов дома. В таком случае будет необходим блок удаленного управления с лицензией, что обойдется в €1300. «Ориентировочно 1-комнатная квартира обойдется в €10 тыс., при использовании оборудования топ-сегмента – вдвое дороже. Хотя примеры есть действительно разные. В практике был случай, когда только оборудования (без учета проектных работ, электроразводки и даже без мультимедийной системы) на дом площадью 1200 кв. м было закуплено на €160 тыс.», – рассказывает эксперт.\n\nСамое бюджетное компромиссное решение, основанное на импортных составляющих, может обойтись и в $3-4 тыс., если речь будет идти только об управлении освещением и климатом.\nЗаявленная стоимость комплектов «умного дома» от украинцев составляет $100-1000, в состав которых могут входить как несколько умных розеток и выключателей, так и датчики движения, затопления и дыма.\nЧастный дом обходится дороже, чем квартира. Причиной этому служит не только более обширная площадь, как это бывает зачастую, но и большее число систем, которыми нужно управлять, например, индивидуальное отопление. По словам эксперта, стоимость установки «умного дома» в квартире и особняке сравнимых размеров может отличаться в 2-3 раза.\nОправданы ли такие затраты? Участники рынка утверждают, что да. Во-первых, говорят они, это удобно, во-вторых – экономно. «Не остается ненужное освещение, нет лишних расходов на электричестве, работает система климатконтроля по каждой комнате. В частном доме экономия ощутимей, чем в квартире – в сезон на отоплении можно сэкономить до 60%».\n Задумываться об установке системы «умный дом», говорят эксперты, лучше на этапе проектирования. Во-первых, это удешевляет работы по прокладке необходимых коммуникаций, во-вторых, позволяет наиболее рационально спланировать всю систему и, в-третьих, позволяет сделать ее более высокофункциональной.\n Как объясняет эксперт, производители предлагают более широкий ассортимент проводных технологий, нежели беспроводных. «Конечно, если ремонт уже сделан и не хочется штробить стены и заниматься прочими грязными работами, можно установить беспроводные системы. Но их предлагают не все производители, а их функционал ограничен. К тому же, планирование на самом раннем этапе строительства и ремонта позволяет сократить расходы на систему на 20%».\n\nУчтя это обстоятельство, одна компания взялась за проект строительства первого «умного дома» в целом жилом комплексе. Сейчас, рассказывает директор по развитию бизнеса компании, этот дом, находящийся в Тюмени, находится на начальном этапе строительства. Эксперт признает, что это достаточно смелый эксперимент, в ходе которого стоимость строительства получается несколько выше, чем обычно, но говорит, что заказчик объекта все просчитал и пришел к выводу, что спрос на такие квартиры будет. Идея в том, чтобы изначально спроектировать объект так, чтобы в каждой квартире были заложены коммуникации под «умный дом», а спецификацию и функционал покупатели смогут выбирать самостоятельно.\n\nПравда, констатирует эксперт, пока маловероятно появление подобного жилого комплекса в Украине. «Затраты на строительство не очень отличаются, но вот платежеспособность покупателя совершенно разная. Пока что для Украины такой объект – слишком дорого».', 2, '2016-03-03 17:26:54', 'post_image-63.jpeg', 180),
(56, 'На Прикарпатті хочуть побудувати новий гірськолижний курорт – конкурент \"Буковелю\"', 'Івано-Франківська обласна державна адміністрація розробить проектно-кошторисну документацію на будівництво нового гірськолижного курорту у Верховинському районі, який зміг би конкурувати з \"Буковелем\".\n\nПро це на засіданні постійної депутатської комісії облради з питань європейської інтеграції, міжнародного співробітництва, інвестицій та розвитку туризму повідомив директор департаменту міжнародного співробітництва, євроінтеграції та розвитку туристичної інфраструктури ОДА Дмитро Романюк.\n\nІвано-Франківська обласна державна адміністрація у 2016 році планує взяти участь у великих інвестиційних проектах, які б дали максимальний результат. Одним з таких проектів є будівництво гірськолижного курорту у Верховинському районі.\n\n\"Ми розуміємо, що гірськолижний курорт \"Буковель\" за 10 років дав можливість збільшити кількість туристів, які приїжджають в область. Але і тут є певні проблеми, оскільки будь-який монополіст може зловживати з позиції вартості послуг\", – говорить Дмитро Романюк.\n\nДепартамент планує виготовити проектно-кошторисну документацію для будівництва нового гірськолижного курорту, що у майбутньому дозволить легше залучити нового інвестора уже під готовий проект будівництва другого гірськолижного курорту у Верховинському районі.\n\n\"Верховинський район за своїми природно-кліматичними особливостями цілком відповідає вимогам. Верховинський район є депресивним з приводу залучення інвестицій, а реалізація цього проекту дозволить підвищити там соціально-економічні показники. Така амбітна у нас ціль\".\n\nВін зазначив, що будівництво нового гірськолижного курорту вплине на зниження цін на послуги ТК \"Буковель\".\n\n\"Будь-яка конкуренція призводить до підвищення якості послуг та здешевлення цін\", – підсумував Романюк.\n', 2, '2016-03-06 15:54:53', 'post_image-64.jpeg', 72),
(57, 'Важные нюансы уплаты военного сбора при отчуждении недвижимости', 'Уплата военного сбора в случае нотариального удостоверения договоров купли-продажи недвижимости осуществляется налогоплательщиком по месту нотариального удостоверения.\n\nВ случае, если плательщик налога при нотариальном удостоверении в 2015 году договоров купли-продажи объектов недвижимости не уплачивает военный сбор, то такой плательщик до 1 мая 2016 года подает годовую налоговую декларацию в контролирующий орган по месту налогового адреса и уплачивает сумму налогового обязательства до 1 августа 2016 года. К такому выводу пришла ГФС в письме № 2032/С/99-99-17-03-03-14.\n\nОтметим, пп. «в» п. 176.1 ст. 176 НК установлено, что плательщики налога обязаны подавать налоговую декларацию по установленной форме в определенные сроки в случаях, когда согласно нормам раздела IV НК такое представление является обязательным.\n\nОднако в соответствии с этим разделом обязанность плательщика налога относительно представления налоговой декларации считается выполненной и налоговая декларация не подается, если такой плательщик налога получал доходы от операций продажи (обмена) имущества, дарения, при нотариальном удостоверении договоров по которым был уплачен налог (сбор) (п. 179.2 ст. 179 НК).\n\nСледовательно, уплата военного сбора в случае нотариального удостоверения договоров купли - продажи недвижимого имущества (квартир) осуществляется налогоплательщиком по месту их нотариального удостоверения. Налоговая декларация в таком случае налогоплательщиком не подается.\n\nВместе с тем согласно пп. 168.2.1 п. 168.2 ст. 168 НК, плательщик налога, получающий доходы от лица, которое не является налоговым агентом, и иностранные доходы, обязан включить сумму таких доходов в общий годовой налогооблагаемый доход и подать налоговую декларацию по результатам отчетного налогового года, а также уплатить налог (сбор) с таких доходов.\n\nПри этом такой плательщик до 1 мая года, наступающего за отчетным, подает годовую налоговую декларацию в контролирующий орган, где состоит на учете, в которой отражает указанный доход (пп. 49.18.4 п. 49.18 ст. 49 НК).\n\nВ соответствии с п. 179.7 ст. 179 НК физлицо обязано самостоятельно до 1 августа года, наступающего за отчетным, уплатить сумму налогового обязательства, указанную в представленной им налоговой декларации.', 2, '2016-03-13 11:15:49', 'post_image-65.jpeg', 50);
INSERT INTO `posts` (`id`, `title`, `content`, `author_id`, `date`, `image`, `views`) VALUES
(58, 'Как защитить в новостройке имущественные права?', 'Приобретение недвижимости в строящемся доме кроет в себе определенные риски, среди которых:\nобнаружатся нарушения в разрешении на строительство;\nзастройщик обанкротится; \nи многое другое. \nВ итоге инвестор может потерять свои деньги, которые будет трудно вернуть, и, что еще обиднее, можно остаться без желанной квартиры в новостройке. Рассмотрим, как минимизировать риски и защитить свои права.\n\nНюансы приобретения квартиры в новостройке:\nВнесение всей суммы за квартиру согласно договору купли-продажи имущественных прав, не дает гарантий и не делает покупателя владельцем – ведь он, по сути, отдает деньги за право (возможность) получения объекта недвижимости в будущем.\n  Сегодня существует несколько законодательно утвержденных способов приобретения недвижимости на первичном рынке: \n	покупка целевых облигаций; \n	фонд финансирования строительства; \n	институт совместного инвестирования (Закон Украины «Об инвестиционной деятельности», статья 4). \nСпорность ситуации (как в случае с описанным выше решением Верховного Суда) заключается в том, что возможность отчуждения имущественных прав на квартиры первичного рынка описаны и в нормах Гражданского Кодекса. Этим пользуются некоторые застройщики, предлагая покупателям различные инвестиционные договоры (купли-продажи имущественных прав, предварительный договор), не дающие инвестору юридической гарантии.\nПодобных договоров стоит по возможности избегать, так как получается, что по смыслу договора имущественные права так и не возникли, а значит инвестор и не может оспаривать недвижимое имущество как свою собственность.\n\nИмущественные права: как их защитить? \nЧтобы избежать попадания в такую ситуацию, следует внимательно относиться к выбору застройщика. Необходимо обязательно проверить его надежность до заключения сделки. Прежде всего, следует обратить внимание на наличие и актуальность разрешительной документации (утвержденный проект жилого дома и его экспертиза, разрешительный акт на проведение строительных работ и прочее) – добросовестный застройщик не будет ничего скрывать и всегда любезно предоставит интересующую информацию (в том числе и копии для лучшего ознакомления).\n Не забудьте заглянуть на тематические форумы (такие есть практически по любому застройщику или жилому комплексу) и другие ресурсы (например, градостроительный кадастр http://monitor.mkk.kga.gov.ua/). К сожалению, сегодня потенциальный покупатель не имеет возможности проверить финансовые дела девелопера, ибо его тщательно скрывают, чтоб не подорвать доверие инвесторов.\n\nЕсли вы убедились в добросовестности застройщика, переходите к покупке недвижимости, приобретая целевые облигации, участвуя в фонде финансирования строительства или институте совместного инвестирования. Однако даже такое развитие событий из-за отсутствия единого реестра строящегося жилого фонда и правил его регистрации не спасет покупателя от двойных продаж и залогов. В тоже время отсутствие в нашей судебной системе прецедентного права делает возможным ситуацию, что решения разных инстанций на основе одной законодательной базы будут различаться. Стоит отметить, что государство постепенно делает успешные шаги в этом направлении. Так, согласно вступившим в силу изменениям к ЗУ «Про державну реєстрацію речових прав на нерухоме майно та їх обтяжень» будет осуществляться регистрация имущественных прав на недвижимость, находящуюся в стадии строительства. Таким образом, покупатель становится обладателем вещного права и гарантирует себе в дальнейшем (после принятия дома в эксплуатацию и оформления сопутствующих документов) право собственности на эту квартиру.\n\"\"', 2, '2016-03-23 16:16:51', 'post_image-68.jpeg', 58),
(59, 'Кредит на квартиру в новостройке (новом доме): как выбрать подходящий вариант?', 'Покупка квартиры в новостройке – это одно из потаенных желаний каждого человека. Но далеко не всегда у покупателя оказывается достаточно материальных средств для столь дорогого приобретения. Один из выходов в такой ситуации – воспользоваться услугами банка и оформить кредит.\n\nОсобенности украинского кредитования первичного жилья:\nСтоит отметить, что хоть украинский банковский сектор и имеет большое количество участников, однако лишь их малая часть на сегодняшний день готова предоставлять населению услуги по кредитованию на покупку жилья на первичном рынке. Так что в конце текста мы приводим таблицу с наиболее подходящими условиями для этого. Финансовые учреждения различаются – сроками, процентными ставками, суммой минимального аванса и прочими нюансами, на которые следует обращать внимание при подписании договора. Также необходимо учитывать, что банки не предоставляют кредитную сумму в размере полной стоимости квартиры. А кредиты выдаются под залог покупаемого жилья. Обязательно читайте мелкий текст и текст, помеченный звездочкой(*). Это поможет вам максимально точно понимать условия, на которых вы получаете кредит и избежать скрытых комиссий и переплат.\n\nДокументы:\nПомимо стандартных (паспорт, код, справка о доходах), когда вы берете кредит на квартиру, могут понадобиться следующие документы: \n	свидетельство о браке; \n	копии документов супруга; \n	копия трудовых книжек обоих супругов; \n	документы, в которых указан дополнительный доход (договор аренды, проценты по депозитам и прочее); \nправоустанавливающие документы на прочее движимое или недвижимое имущество, которое может выступить залогом кредита. \nКоличество документов зависит от вашей официальной зарплаты, и если ее достаточно для выплаты кредита, то документы о дополнительных доходах не нужны. \n\nПроцесс подачи документов в банк.\nВопреки расхожему мнению, процесс достаточно быстрый. Вы назначаете дату и время своего визита, берете все необходимые документы и приходите. В среднем, вы потратите в банке не более трех часов. Час заполняются документы, затем кредитный менеджер вместе с вами все перепроверяет, вы внимательно читаете договор и подписываете его.\n\nВозможная переплата.\nПереплата зависит от двух факторов: срок, на который вы берете кредит и годовых процентов банка. Так, минимальный годовой процент на сегодняшний день – 19,5% при минимальном первоначальном взносе 20%. И если вы покупаете квартиру стоимостью 30000$, то 6000$ вы должны будете внести сразу.\n\nЮрист: \nПри изучении условий договора следует обратить внимание: \n	- условия кредитования; \n	- на наличие явных и скрытых комиссий банка за обслуживание кредита и условия их выплаты заемщиком; \n	- на условия начисления процентов; \n	- график и порядок погашения тела кредита и процентов за пользование им.\nИтого остается 24000 $, которые можно взять максимум на 20 лет. Переплата за 5 лет составит примерно 23000 $. Но это только примерные цифры, так как это во многом зависит от того, какой платеж предлагает вам банк.\n\nВозможные виды платежа по кредиту.\nСуществует два основных вида платежей: \n1) Аннуитетный; \n2) Дифференцированный. \nРассмотрим детальнее каждый из них.\n\nАннуитетный платеж - он представляет собой равные части, которые клиент оплачивает на протяжении всего кредитного срока. \n	В сумму такого платежа включаются: \n	тело кредита; \n	банковский процент; \n	различные комиссии банковского учреждения (если они есть). \nПервую половину срока большую часть вашего платежа будут составлять проценты и комиссии, а меньшую – основное тело кредита. А уже ближе к его концу пропорция изменится, и уже большая часть будет состоять из основного долга. \nТаким образом, досрочное погашение не так уж и выгодно.\n\nДифференцированный платеж - это ежемесячные транши, которые уменьшаются в определенной пропорции на протяжении всего срока. Так, в первую половину срока будут самые большие суммы, а к концу они составят четверть от первоначальной. Каждый месяц основной долг уменьшается, а проценты насчитываются уже на остаток. Досрочные выплаты в этом случае могут помочь существенно сэкономить.\n\nУсловия кредитов от украинских банков.\nМы собрали информацию по десяти украинским банкам, которые предлагают интересные условия кредитования жилья в разных городах. Вся информация взята из открытых источников и официальных сайтов компаний.\n\nУкргазбанк  www.ukrgasbank.com  От 20% 20 лет от 19,5% \nUniCredit Bank https://ru.unicredit.ua/ От 40% 20 лет от 22,3% \nКредобанк www.kredobank.com.ua От 15% 20 лет от 21,49% \nАркада http://arkada.ua/ От 30% 30 лет от 20% \nПивденный http://bank.com.ua/ От 30% 3 года от 24,9% \nОщадбанк www.oschadbank.ua/ От 30% 20 лет от 23% \nVS Bank www.vsbank.ua От 40% 20 лет от 23% \nСбербанк www.sberbank.ua От 30% 20 лет от 24% \nИндустиалбанк http://industrialbank.ua/ От 50% 20 лет от 21% \nCredit Agricole https://credit-agricole.ua/ От 50% 20 лет от 23% \n\nПокупателю следует помнить и о дополнительных выплатах, которые банк может вписать в договор:\n	комиссии банку за проведенную операцию (от 1,5%);\n	страховой сбор (от 0,25%);\n	страхование заемщика (от 0,45%);\n	оформление договора (от 2500 грн);\n	государственный налог (от 0,1%);\n	другие траты (в зависимости от условий сделки).\n\nТак, можно сказать, что, если быть внимательным и тщательно просчитать переплату в каждом из предложенных вариантов, можно будет выбрать подходящий вариант. Главное, определиться с приоритетами – низкий процент, возможность максимального срока кредитования или размер первоначального взноса.', 2, '2016-03-23 16:53:33', 'post_image-69.jpeg', 65),
(60, 'Нидерланды построят во Львове индустриальный парк за 80 млн. евро', 'Индустриальный парк будет включать в себя комплекс производственных, складских и офисных помещений, которые будут сдавать в аренду. Комплекс разместят на земельном участке площадью 89 га, который примут в аренду у местных властей.\nКлючевыми клиентами парка станут компании-производители автомобильных комплектующих. С появлением объекта появится 2 тыс. Новых рабочих мест.\nПо словам начальника департамента управления, недвижимостью компании СТР Стефана де Хоя, парк будет первым проектом компании в Украине, но в дальнейшем они намерены увеличить их количество.\nНидерландская компания СТР – один из крупнейших промышленных девелоперов Центральной Европы. В июне прошлого года она выиграла инвестиционный конкурс на развитие индустриального парка Обильное-2 во Львове, где они планируют разместить 20-30 промышленных предприятий.', 2, '2016-04-02 21:16:12', 'post_image-70.jpeg', 40),
(61, 'В Украине - новый порядок правила регистрации', 'Кабинет министров Украины утвердил правила регистрации места проживания и порядок передачи органами регистрации информации в Единый государственный демографический реестр. Об этом говорится в правительственном постановлении от 2 марта 2016 года №207.\n\nСогласно принятым правилам, регистрация/снятие с регистрации места проживания/пребывания осуществляется исполнительным органом сельского, поселкового или городского совета, сельским головой (в случае, когда в соответствии с законом исполнительный орган сельского совета не создан), на территории соответствующей административно-территориальной единицы, на которую распространяются полномочия соответствующего сельского, поселкового или городского совета.\n\nГражданин Украины, а также иностранец или лицо без гражданства, которые постоянно или временно проживают в Украине, обязаны в течение 30 календарных дней после снятия с регистрации места проживания и прибытия к новому месту проживания зарегистрировать свое место проживания.\n\nРегистрация места проживания/пребывания или снятия с регистрации места проживания лица осуществляется в день подачи лицом либо его представителем документов. \n\nРегистрация места проживания по заявлению лица может быть осуществлена одновременно со снятием с предыдущего места проживания.\n\nРегистрация места проживания осуществляется только по одному адресу.\n\nДля регистрации места проживания лицо или его представитель подает:\n1) заявление;\n2) документ, в который вносятся сведения о месте проживания;\n3) квитанцию об уплате административного сбора;\n4) документы, подтверждающие:\n– право на проживание в жилье (например, ордер, свидетельство о праве собственности, договор найма (поднайма, аренды), решение суда, вступившее в законную силу, о предоставлении лицу права на вселение в жилое помещение и такое прочее);\n– право на пребывание или взятие на учет в специализированном социальном учреждении, учреждении социального обслуживания и социальной защиты лица — справка о принятии на обслуживание в учреждении, заведении (для лиц, состоящих на учете в этих учреждениях или учреждениях);\n– прохождение службы в военной части, адрес которой указывается при регистрации, — справка о прохождении службы в воинской части (для военнослужащих, кроме срочников);\n5) военный билет или удостоверение о приписке (для граждан, подлежащих взятию на воинский учет или находящихся на воинском учете);\n6) заявление о снятии с регистрации места проживания лица (в случае осуществления регистрации места жительства одновременно со снятием с регистрации предыдущего места жительства).\nВ случае подачи заявления представителем лица дополнительно предоставляются:\n– документ, удостоверяющий личность представителя;\n– документ, подтверждающий полномочия лица как представителя, кроме случаев, когда заявление подается законными представителями малолетнего ребенка — родителями (усыновителями).\nЗапрещается требовать для регистрации места проживания лица другие документы.\n\nТакже в постановлении говорится, что передача информации о регистрации/снятии с регистрации места проживания/пребывания физических лиц из реестров территориальных общин в Единый государственный демографический реестр осуществляется после введения в эксплуатацию соответствующих программных средств.\n\nНа период до 1 января 2017 года информация от исполнительных органов сельских, поселковых, городских советов, их должностных лиц, сельских голов, осуществляющих регистрацию/снятие с регистрации места проживания/пребывания в Единый государственный демографический реестр может передаваться в бумажном и электронном виде.\n\nНа сегодняшний день в Украине практически половина трудоспособного населения проживает не по месту регистрации, что создает определенные проблемы самим гражданам, которые вынуждены применять коррупционные схемы, чтобы получить административные и медицинские услуги.\"', 2, '2016-04-07 23:24:21', 'post_image-71.jpeg', 157),
(62, 'Как правильно составить задаток при покупке недвижимости, покупателю?', 'При покупке квартиры, Вы часто слышите такое слово как «задаток», без которого не обходится ни одна сделка купли-продажи. Но зачастую многие покупатели путают «задаток» с понятием «аванса». Поэтому в данной статье речь пойдет именно о «задатке», его определении и значимости для покупателя.\n\nИтак, что такое «задаток»?\nВ соответствии с нормами Гражданского кодекса Украины (далее – ГК Украины) задатком является денежная сумма или движимое имущество, которое выдается кредитору (продавцу квартиры) должником (покупателем квартиры) в счёт причитающихся с него по договору платежей, в подтверждение обязательства и в обеспечение его выполнения.\n\nТаким образом, задаток одновременно выступает и способом платежа, и способом обеспечения исполнения обязательств, так сказать, гарантия выполнения обязательств со стороны продавца, что немаловажно для покупателя. Поскольку в случае нарушения обязательств со стороны продавца, задаток покупателю возвращается в двойном размере. В случае же невыполнения обязательств самим покупателем, внесённая им сумма задатка остается у продавца.\nНО! Возмещение покупателю задатка в двойном размере будет возможно лишь в том случае, когда, во-первых, договорные отношения между покупателем и продавцом оформлены в соответствии с требованиями гражданского права, а именно в письменной форме (ст. 547 ГК Украины), а во-вторых, когда при его оформлении будет четко указано, что денежная сумма, которая передаётся продавцу, является задатком, иначе в противном случаем это будет аванс.\n\nКак оформить передачу «задатка», чтобы в последствии не оказаться и без квартиры, и без денег?\nНередкими на практике есть случаи передачи задатка по заключённым «юридически незащищённым», на мой взгляд, договорам о задатке, договорам о намерениях, либо же вообще на основании простых расписок. Все это в последствии приводит к затяжным судебным процессам, решения по которым принимаются далеко не в пользу покупателя.\n\nВ какой форме оформить передачу задатка?\nИсключительно в письменной форме. Причём, речь не идет о банальной расписке о получении денежных средств. Расписка в данном случае не будет допустимым доказательством оформления сделки по обеспечению обязательства в письменном виде. Иными словами, условие о задатке необходимо прописать в самом (основном) договоре, который им и обеспечивается, а также сделку о задатке можно оформить путём заключения дополнительного соглашения к основному договору.\n\nКакие документы необходимы для оформления задатка?\nЮридически правильным способом оформления задатка является либо его указание в основном договоре, либо же в дополнительном соглашении к основному договору купли-продажи квартиры. Поэтому неотъемлемым этапом оформления задатка является непосредственно наличие полного пакета документов как на объект недвижимости, так и документов, удостоверяющих полномочность прав сторон данной сделки (продавца и покупателя).\nИтак, покупатель от продавца должен запросить:\n\n- оригинал паспорта и идентификационного кода;\n- оригинал правоустанавливающих документов на квартиру (это может быть договор дарения, свидетельство о права на наследство с отметкой о государственной регистрации права собственности, нотариально удостоверенный договор купли-продажи квартиры, свидетельство о праве собственности, решение суда, информационная справка с Государственного реестра регистрации прав на недвижимое имущество);\n- документы по технической характеристике объекта (справка БТИ). Перепроверьте данные с правоустанавливающими документами, так как нередкими бывают случаи, когда была проведена перепланировка, но документы не были приведены в соответствие с действующим законодательством – нет документов от органов архитектурно-строительного контроля, объект не введён в эксплуатацию, информация соответственно не нашла своего отображения в государственных реестрах, что в последствии может стать камнем преткновения, увеличивающим как материальную сторону сделки, так и её часовые рамки;\n- документы, удостоверяющие родственные связи (свидетельство о браке, о смерти, брачный договор);\n- информацию о наличии несовершеннолетних детей и их прописке в данной квартире (поскольку процедура выписки несовершеннолетних детей более долгая и требует согласования с органами опеки и попечительства местных (районных) органов исполнительной власти).\n\nБолее того, Вы также можете самостоятельно перепроверить данные по объекту (в т. ч. наличие обременений по имуществу) через Госреестр вещных прав на недвижимое имущество, используя данные как по продавцу (идентификационный код и паспортные данные), так и по адресу объекта (квартиры), и это, в свою очередь, будет на порядок дешевле услуг нотариуса, который также это сможет перепроверить в момент совершения сделки купли-продажи ( https://kap.minjust.gov.ua/ ).\n\nНемаловажной может быть информация о наличии судебных споров по объекту. В данном случае можно поискать информацию в Едином реестре судебных решений. Единственное, что данные физлица (его Ф.И.О.) в открытом доступе отсутствует, но по адресу и идентификационным данным объекта недвижимости можно попробовать промониторить данные (поисковая система очень проста в использовании: http://www.reyestr.court.gov.ua/ .\n\nПри оформления задатка, покупателю при себе же необходимо иметь: паспорт и идентификационный код, документы, удостоверяющие родственные связи (свидетельство о браке либо о его расторжении).\nСопоставьте данные, указанные в документах, удостоверяющих личность продавца, с данными, указанными в правоустанавливающих документах, наличие дописок, описок, и т.д.\n\nСуществуют ли законодательно установленные сроки, в течении которых необходимо передать задаток?\nДействующим законодательством не установлены ни минимальные, ни максимальные сроки внесения задатка. Это всё оговаривается сторонами (покупателем и продавцом). На совершении сделки влияют как объективные, так и субъективные причины, а задаток в данному случае является способом обеспечения сделки. К причинам, которые влияют на сроки, можно отнести фактическую готовность всех документов на квартиру (справок-характеристик, формы № 3, справок о наличии или отсутствии долгов, выписки с квартиры и т.д.). Главное в данном случае – указать все эти моменты в договоре, поскольку в случае невыполнения обязательства, каждая из сторон несёт ответственность (покупатель лишится суммы задатка, а продавцу придётся вернуть его в двойном размере). Желательно прописать в договоре отдельным разделом форс-мажорные обстоятельства, в случае наступления которых речь о штрафных санкциях идти не может.\n\nВ каком размере должен быть передан задаток?\nКак и в случае со сроками передачи задатка, законодательством не предусмотрено его чёткого размера. Исходя из практики, размер задатка может варьироваться от 2% до 5% стоимости квартиры. Но необходимо учитывать, что на стоимость квартир в целом может повлиять ситуация на рынке недвижимости, в частности, квартиры могут вырасти в цене, и в таком случае, продавцу может быть не выгодно выполнять условия договора по уже договорённой цене, а проще вернуть задаток даже в двойном размере, но при этом остаться в плюсе при продаже квартиры за более высокую цену, а Вам придется искать другие варианты, возможно даже менее привлекательные.\n Срок передачи задатка в свою очередь может сыграть на руку продавцу. Так, в случае продажи объекта недвижимости, владение которым осуществляется на протяжении 3 лет, доход от данной сделки не облагается налогом, при условии совершения сделки в течении отчётного налогового года. Поэтому в данном случае с позиции продавца Вам может быть предложено установить временные рамки в данном диапазоне (в зависимости от фактического срока владения квартирой).\n\nЕсли обязательство не исполняется, что происходит с задатком?\nПравовые последствия нарушения или прекращения обязательства, обеспеченного задатком урегулированы в статье 571 ГКУ. В частности, если нарушение обязательства произошло по вине должника – задаток остаётся у кредитора, а если нарушение обязательства произошло по вине кредитора, то он (кредитор) обязан вернуть должнику задаток и дополнительно оплатить сумму в размере задатка (его стоимости, если задаток выражен в движимом имуществе). Кроме этого, частью второй ст. 571 ГКУ предусмотрено, что сторона, виновная в нарушении обязательства, должна возместить второй стороне убытки в сумме, превышающей размер (стоимость) задатка, если иное не предусмотрено договором. Также следует обратить Ваше внимание на положение статьи 627 ГКУ, в соответствии с которой стороны являются свободными в заключении договора, выборе контрагента и определении условий договора с учётом требований этого Кодекса, иных актов гражданского законодательства, обычаев делового оборота, требований разумности и справедливости. Поэтому, если в договоре Вы указываете, что в случае разрыва договора, сумма возмещения будет равна стоимости квартиры, это не противоречит свободе договора, другое дело, пойдёт ли на это продавец, понимая риски, и в любом случае, чтобы убытки были возмещены в таком размере, придётся для начала доказать, что они реально были причинены именно в такой сумме.\n\nНеобходимо ли нотариальное удостоверение сделки по обеспечению обязательств?\nУсловие относительно обязательного нотариального удостоверения сделок по обеспечению обязательств действующим законодательством не предусмотрено. В свою очередь, вы имеете полное право потребовать нотариального удостоверения данной сделки, поскольку данное право Вам предоставлено в силу положений п. 4 ст. 209 ГК Украины, согласно которому, по требованию физического или юридического лица любая сделка с его участием может быть нотариально удостоверена.\n Кроме того, нотариальное удостоверение сделки по обеспечению обязательств возможно в случае, если условие о задатке прописано в самом содержании договора, обязательность нотариального удостоверения которого предусмотрена законодательством, а также в случае обеспечения обязательств по договору купли-продажи квартиры путём составления и подписания дополнительного соглашения к основному договору. В таком случае, данное соглашение должно быть обязательно нотариально удостоверено в соответствии с требованиями ст. 654 ГК Украины, согласно которой изменение договора совершается в той же форме, что и договор, который изменяется, если иное не установлено договором или законом, или не вытекает из обычаев делового оборота.\n\nЕсть ли ещё варианты оформления задатка?\nВам предложили заключить договор о задатке, ссылаясь на положение ст. 6 ГК Украины (относительно права сторон заключить договор, непредусмотренный законодательством, и урегулировать взаимоотношения на собственный лад). В данном случае применять его к сделке купли-продажи квартиры нельзя. Поскольку этой же статьёй установлены рамки таких действий, а именно стороны не вправе так поступать, если это прямо запрещено законом или противоречит сути отношений сторон. Поэтому, заключение таким способом договора задатка противоречит его сути–задатком можно обеспечить только уже возникшее обязательство (ст. 570 ГК Украины).\n\nУплата задатка по договору о намерении (предварительный договор).\nЕщё одним, довольно-таки юридически приемлемой формой оформления задатка, может быть договор о намерении (предварительный договор).\nНО! Договор о намерении (предварительный договор) не относится к денежным обязательствам, он всего лишь предусматривает обязательства его сторон заключить в дальнейшем основной договор. А такое обязательство не является денежным и поэтому обеспечивать его задатком нельзя.\n\nЗалогом можно обеспечить только такое денежное обязательство, которое уже существует. К примеру, по договору купли-продажи квартиры денежное обязательство возникнет только после заключения такого договора и его государственной регистрации в соответствии с законом.\n\nПоэтому, придерживайтесь указанных выше рекомендаций, как говорится на латыни: «Praemonitus praemunitus», что означает: «Кто предостережен, тот вооружен».', 2, '2016-04-11 21:28:14', 'post_image-72.jpeg', 118),
(63, 'Проблемы с выплатой кредита: советы, как выпутаться из ситуации', 'Хорошая кредитная история, вовремя погашены займы и уплаченные проценты - это то, что делает вас желанным клиентом любых финансовых учреждений. В этих условиях без проблем дают кредиты и предлагают программы лояльности. Однако даже добросовестные заемщики иногда попадают в затруднительное положение. Неожиданное освобождение, внезапная болезнь и потеря работоспособности могут помешать вовремя погасить кредит.\nЧто делать в таком случае? Как избежать штрафов и пени за просрочку?\nПервое правило - не паниковать. Второе - сразу уведомить кредитора о своих проблемах. Ни в коем случае не стоит прятаться или избегать общения с заимодавцем. Специалисты рекомендуют сначала обратиться к кредитору с письмом, описав объективные причины, мешающие вам погасить задолженность в срок. Можете даже добавить документы, подтверждающие ваши трудности, например, медицинскую справку. После этого следует подкрепить свое письмо звонком или личным визитом в офис.\n\nВсе финансовые учреждения (как банки, так и кредитные компании) понимают текущую ситуацию в стране и всегда готовы идти навстречу клиенту. Вам могут предложить несколько выходов из ситуации:\n1. Пролонгация\nКогда вы понимаете, что вам не удастся своевременно погасить кредит, можете оформить пролонгацию - продление срока выплаты обязательств по кредиту при условии уплаты всех начисленных процентов. Если же вы взяли кредит через онлайн сервис, то пролонгировать его можно даже самостоятельно, без общения с работниками компании. Достаточно выбрать соответствующий пункт меню в своем личном кабинете. Сервис онлайн кредитов Moneyveo позволяет пролонгировать кредит на срок до 30 дней неограниченное количество раз.\n2. Реструктуризация\nУслуга реструктуризации предусматривает уменьшение ежемесячных платежей с одновременным продлением срока погашения долга. При этом когда и сколько платить решают с клиентом индивидуально. Каждая кредитная организация предлагает собственные программы реструктуризации.\n3. Кредитные каникулы\nКредитные каникулы - это временный перерыв в платежах на определенный срок. В это время проценты обычно не начисляются или существенно снижают. Этот вариант оптимален, когда платить по кредиту нечем силу временных обстоятельств, например, госпитализацию на несколько месяцев.\n\nПомните: с каждым должником, попавшего в беду, финансовые учреждения работают индивидуально и всегда могут подобрать компромиссные условия, выгодные для обеих сторон, ведь кредиторы в конце концов также заинтересованы в том, чтобы вернуть свои средства.', 2, '2016-04-14 14:03:46', 'post_image-73.jpeg', 51),
(64, 'Что ждет Украину и все человечество в 2050 году?', 'К середине века мы застроим планету мегаполисами, выловим всю рыбу и потеряем остатки приватности в цифровом мире. Звучит, словно предсказание апокалипсиса? К сожалению, это серьезные научные выкладки. Никаких летающих машин или городов в облаках — реальность окажется более суровой.\n\n1. Две трети людей будут жить в городах-трущобах!\nВ 2050 году горожанами станут 6,3 млрд человек. Для сравнения, сейчас все население Земли немногим больше — 7,3 млрд. Но города станут похожи не на любимые фантастами сверхсовременные мегаполисы, а на сегодняшний Мехико. Дело в том, что города быстрее всего растут в бедных странах, где у граждан нет денег на полноценное жилье. Люди селятся в зданиях без канализации и водопровода. А властям развивающихся стран не хватает денег на новые дома, школы и больницы. Поэтому дальнейший рост городов грозит эпидемиями и всплеском преступности.\n Даже богатым государствам труднее обеспечивать мегаполисы, которые потребляют больше электричества и воды, чем сельские районы. Но в городах проще найти работу, и они будут расти, несмотря на все угрозы.\n\n2. Автомобили и бытовая химия отравят воздух озоном!\nГлавными загрязнителями атмосферы станут не заводы, а автомобили, бытовая химия и стройматериалы, ведь они выделяют озон, поражающий легкие. Глобальное потепление ускорит химические реакции, превращающие озон в яд, а растущим городам понадобится больше транспорта и стройматериалов. К 2050 году этот газ будет убивать 6 миллионов человек ежегодно. Кроме озона, в воздухе вырастет доля углекислого газа, тяжелых металлов и кислот. Все «благодаря» тепловым электростанциям и сжиганию мусора.\n Украину промышленным гигантом не назовешь, но смертность от загрязнения воздуха у нас уже выше, чем в Германии или Японии. Наши ТЭЦ устарели и часто работают без фильтров, да и качество медицины у немцев и японцев выше. \n\n3. Воды хватит только половине жителей Земли!\nС ее недостатком столкнутся не только пустынные страны, но и, например, США или Германия. Дело не в том, что людей станет слишком много, это воды будет слишком мало. Треть мировых рек, возможно, исчезнут по разным причинам. Сегодня миллиард человек испытывают нехватку воды — в будущем их станет 5 миллиардов.\nИз них 2 миллиарда будут жить в безводных регионах Африки и Ближнего Востока. Эти страны лишатся возможности поливать поля и поддерживать гигиену, что грозит голодом и эпидемиями. Даже если воды хватает, при неправильной очистке она становится непригодной для питья.\n\n4. В океанах истощатся запасы рыбы!\nОстровные и прибрежные страны в прямом смысле живут за счет морепродуктов. Исчезновение рыбы лишит заработка около 700 миллионов людей — больше, чем живет во всем Евросоюзе. Сильнее всего пострадают развивающиеся страны. Экспорт морепродуктов приносит им около 65 миллиардов долларов в год, а 3 миллиардам жителей рыба позволяет нормально питаться. Но 87% рыбных запасов истощены. Чтобы сохранить их, нужно ограничивать вылов. То есть небогатым странам придется отказаться от чуть ли не единственного прибыльного экспорта и найти работу для бывших рыбаков. Без международной поддержки и системы квот вроде Киотского протокола они вряд ли на это пойдут. В таком случае нам грозит продовольственный кризис и нехватка лекарств — их тоже делают из морепродуктов.\n\n5. Падение урожаев вызовет голод!\nК середине века человечеству понадобится на 14% больше еды, чем сейчас. Но урожаи уменьшатся из-за потепления и загрязнения почвы. В следующие 10 лет мы недополучим 4 миллиона тонн продуктов. В 2050 году зерна станет на 10% меньше, потребителей — больше, и цены на него вырастут вдвое. Морепродукты также подорожают или исчезнут. Африке и Южной Азии угрожает голод: сельское хозяйство там неэффективно, а доходы населения слишком низки.\n\nДумаешь, Украине повезло? Да, голод, как в Африке, нам и правда не грозит. Но нормальное питание получат не все, ведь цены в Украине растут быстрее, чем зарплаты. А вот развитые государства голодать не будут. Швеция или Сингапур производят меньше еды, чем Украина, зато продают готовые товары и услуги, а не зерно и металлолом. Жители промышленных стран получают большие зарплаты, и могут позволить себе хорошо питаться независимо от климата и цены продуктов. \n\n6. Дождевые леса исчезнут!\nТропические леса поглощают углекислый газ и служат источником важных медикаментов. Но люди все равно вырубают их, чтобы освободить землю под посевы. В 2050 году дождевых лесов будет наполовину меньше. Уцелевшие леса будут страдать от засух, вызванных нехваткой воды на Земле.\n\n7. Болезни станут еще опаснее «благодаря» медицине…\nАнтибиотики помогают от разных болезней: от гепатита до насморка. Препараты доступны в свободной продаже, а фермеры дают их животным для профилактики. По сути, врачи «делают прививки» зловредным бактериям. Они привыкают к постоянному действию антибиотиков и получают» иммунитет». Сейчас от подобных инфекций гибнет до 700 тысяч человек ежегодно. А в 2050 году эта цифра вырастет до 10 миллионов, ведь антибиотики используют все чаще. Но если ограничить использование препаратов, бактерии потеряют устойчивость к ним.\n\n8. И будут распространяться быстрее за счет потепления и глобализации!\nМалярия, лихорадка Денге, Эбола — это не полный список болезней, пришедших из экваториальных стран. В теплом влажном климате быстро размножаются как вирусы, так и комары — носители заболеваний. Когда на Земле станет теплее, комары мигрируют в новые регионы, где у людей нет иммунитета, а у медиков — опыта борьбы с малярией или Эболой. Сейчас лихорадка Денге распространена только в тропических странах, но к 2050 году вирус будет угрожать половине населения Земли. Потепление вместе с загрязнением воды вызовет всплеск холеры. \n Эпидемии угрожают всему миру, ведь из зараженной страны можно улететь на самолете в любую точку мира. К примеру, вирус Зика возник в Океании, но путешественники разнесли его по всей планете, превратив в пандемию.\n\n9. Людей с расстройствами психики станет втрое больше!\nВернее, люди будут дольше жить, поэтому количество возрастных заболеваний вырастет. В 2050 году деменцией в разных формах будут страдать 115 миллионов человек. 70% из них будут жить в развивающихся странах. Диагностика и лечение заболевания требуют больших денег и технологий. Для развивающихся стран это станет главным препятствием в борьбе с психическими расстройствами. Но даже в развитых государствах деменцию вовремя распознают только в половине случаев.\n\n10. Ураганы станут намного опаснее!\nВ будущем мощные ураганы, вроде «Сэнди» или «Катрины» будут повторяться раз в несколько лет, а до 2100 года их мощность вырастет в три раза. Из-за глобального потепления водяного пара станет больше, и ураганы начнут возникать чаще.\n\n11. Прибрежные города постепенно уйдут под воду!\nДо середины века уровень воды в океанах поднимется на 40-70 сантиметров из-за таяния ледников. Этого хватит, чтобы затопить прибрежную полосу. Портовые города окажутся в зоне риска: даже небольшие колебания океана вызовут наводнения. В США затопления станут сезонными: всем прибрежным городам грозит до месяца бедствий каждый год. Похожая судьба ожидает и европейские города. Но у американцев и европейцев есть деньги для защиты от наводнений, а вот Юго-Восточной Азии и Океании придется труднее. Во Вьетнаме, например, уйдет под воду дельта реки Меконг — главный сельскохозяйственный регион страны.\n\n12. Люди пожертвуют приватностью ради удобства… или наоборот!\nДенежный перевод, покупка билетов или заказ такси — все это сегодня делают посредством смартфонов. Если его взломают или украдут, преступник сможет снять деньги, получить пароли и другую личную информацию. А взлом странички в Facebook ничем не хуже «жучка» в комнате жертвы. Через несколько лет появятся еще и «виртуальные близнецы» — программа, способная принимать решения, основываясь на персональных данных владельца. Переложить ежедневные покупки или поиск авиабилетов на компьютер — заманчивая идея. Но о приватности придется забыть: программе потребуется максимум информации о пользователе. Данные «виртуальных близнецов» станут потенциальной целью преступников и промышленных шпионов. Впрочем, новая программа сама по себе не несет угрозы. Каждый сам решит, что важнее: удобство или приватность.\n\n13. Хакеры будут разрушать заводы и отключать электричество!\nСтратегические объекты во Вторую мировую уничтожали диверсионные группы, а с разрушением иранского завода справился компьютерный вирус. Хакеры способны не только похищать данные или портить компьютеры, а и вывести из строя оборудование фабрики. А значит, кибератаки способны стать орудием терактов. Взлом компьютерных систем аэропорта или метрополитена грозит не только поломками, но и жертвами. По мнению экспертов, в будущем кибератаки будут уносить жизни и обходиться потерпевшим в миллиарды долларов. Особенно если их организацией займутся не вольные хакеры, а спецслужбы мощных государств или ИГИЛ.\n\nУкраина уже столкнулась с атаками на важную инфраструктуру. Кибератака на нашу энергосеть привела к отключению электричества и утере данных. Последствия могли быть и хуже, если бы хакеры «отключили» прифронтовые города или Киев. По сути, хакерские атаки — еще один вид гибридной войны: нетрудно догадаться, кому это выгодно, но доказать что-либо нельзя. Нужно просто защищаться, благо IT-специалистов у нас хватает.\n\nЖить по принципу «моя хата с краю» больше не получится!\nВпрочем, самых пессимистичных сценариев можно избежать. Необязательно отказываться от производства и раздавать деньги бедным. Масштабные медицинские проекты остановят эпидемии, а новые требования к очистке воды и воздуха предотвратят загрязнение планеты. Тем более, отстраниться от происходящего не получится: наводнения, ураганы и эпидемии угрожают всему миру, а не только бедным странам.\n\nУкраина не уйдет на дно океана, нас разве что подтопит по краям, и не останется без воды. Но чтобы не превратиться в отсталую страну, нужно развивать промышленность и здравоохранение. Если у нас будут высокие доходы и качественная медицина, страна переживет эпидемии и обеспечит себя качественной едой и питьем.', 2, '2016-04-15 21:34:35', 'post_image-74.jpeg', 168),
(66, 'Энергоэффективный дом без проекта - возможно ли это?', 'Проект энергоэффективного сооружения отличается от обычного рядом особенностей. В частности, энергоэффективность здания определяется теплотехническим расчетом.\n\nВ ходе его выполнения можно определить толщину стен и утеплителя, способ утепления перекрытий и кровли, площадь окон и их класс энергосбережения, мощность отопительной системы.\n\nПрофессиональный проект предусматривает отсечение всех возможных мостиков холода: утепление перемычек, цоколя, кровли и т. д. Причем узлы примыкания утеплителя к конструкции могут существенно отличаться от тех, что закладывают в обычных проектах.\n\nНаконец, архитектор подберет наиболее эффективные материалы в конкретном случае с учетом особенностей климата и почв. Так что специальный проект обязателен. Более того, он даст возможность сразу рассчитать количество затрат на энергообеспечение здания.\n\nЭффективное планирование.\n\nПрофессиональный подход подразумевает разработку плана здания с учетом как пожеланий заказчика, так и реальных потребностей. В результате вполне можно обойтись без коридоров и других «лишних» помещений.\n\nОтсутствие дополнительных перегородок дает возможность улучшить вентиляцию, облегчить поддержку правильного температурного режима. Сократится и расход строительных материалов.\n\nТакже не стоит обустраивать подвал, если он на самом деле не потребуется. Вместо второго этажа лучше запланировать мансарду. И не надо делать потолки высотой в 3-3,5 м. При расстоянии от пола до потолочной отделки в 2,7-2,8 м обеспечивается достаточный комфорт проживания, зато уменьшается площадь ограждающих конструкций и оконных проемов.\n\nКак следствие, здание прослужит дольше, не будут появляться продувки, подтеки и т. Д. Можно будет снизить не только затраты на отопление, но и затраты на эксплуатацию и ремонт.', 2, '2016-04-28 22:55:57', 'post_image-75.jpeg', 81),
(67, 'Где в Европе самая низкая ипотечная ставка?', 'В Европе самую низкую фиксированную ставку по ипотечному кредитованию предлагает Швейцария. На данный момент средний показатель составляет 1,75%.\n\nДля сравнения, в Германии кредит на покупку недвижимости сроком на 15 лет можно получить под 1,9% годовых, а в Дании – около 3%.\n\nВ Финляндии большинство банков могут предложить ипотеку по фиксированной ставке 1,83%, в Люксембурге – около 2%.\n\nВ Швейцарии ипотека обычно выдается на небольшой срок – 10 лет. Сумма кредита может достигать 80% от стоимости объекта недвижимости. Финские банки охотнее выдают кредиты на 75% стоимости жилья, однако в некоторых случаях возможна 100%-ая ипотека на срок до 25 лет.\n\nВ Люксембурге можно получить ипотеку на срок до 30 лет на 80% от стоимости объекта недвижимости.', 2, '2016-05-09 13:08:17', 'post_image-76.jpeg', 90),
(68, 'Какие нюансы уплаты налога при обмене недвижимости', 'Обмен двух квартир на жилой дом с целью налогообложения следует рассматривать как продажу отдельных объектов недвижимого имущества независимо от того, что данная сделка оформлена одним договором. При этом к каждому из объектов должны быть применены положения ст. 172 Налогового кодекса, разъяснила ГФС в письме № 4302/М/99-99-13-02-03-14.\nСогласно п. 172.1 ст. 172 НК доход, полученный плательщиком налога от продажи (обмена) не чаще 1 раза на протяжении отчетного налогового года жилого дома, квартиры или их части, комнаты, садового (дачного) дома, а также земельного участка, не превышающего нормы бесплатной передачи, определенной ст. 121 ЗК, в зависимости от его назначения и при условии пребывания такого имущества в собственности плательщика налога свыше 3 лет, не облагается налогом.\n\nУсловие относительно пребывания такого имущества в собственности плательщика налога свыше 3 лет не распространяется на имущество, полученное таким плательщиком в наследство.\n\nСогласно п. 172.2 ст. 172 НК доход, полученный плательщиком налога от продажи в течение отчетного налогового года более 1 из объектов недвижимости, указанных в п. 172.1 НК, или от продажи объекта недвижимости, не указанного в этом пункте, подлежит налогообложению по ставке 5 %, определенной п. 167.2 ст. 167 НК.\n\nПод продажей понимается любой переход права собственности на объекты недвижимости, кроме их наследования и дарения (п. 172.8 ст. 172 НК).\n\nДоход от продажи объекта недвижимости определяется исходя из цены, указанной в договоре купли-продажи, но не ниже оценочной стоимости такого объекта, рассчитанной органом, уполномоченным осуществлять такую оценку (п. 172.3 ст. 172 НК).\n\nВо время проведения операций по продаже (обмену) объектов недвижимости между физлицами нотариус удостоверяет соответствующий договор при наличии оценочной стоимости такого недвижимого имущества и документа об уплате налога в бюджет стороной (сторонами) договора и ежеквартально подает в контролирующий орган по месту расположения государственной нотариальной конторы или рабочего места частного нотариуса информацию о таком договоре (п. 172.4 ст. 172 НК).\"\"', 2, '2016-05-14 19:38:39', 'post_image-79.jpeg', 116),
(69, 'Покупка новостроя в Польше от А до Я', '1. Выбрали конкретное предложение от компании-застройщика.\n\n2. Оплатили залог. Ориентировочно от 3 до 5 тысяч злотых. Он потом учитывается при первом платеже и не возвращается, если Вы передумали.\n\n3. Через месяц или больше подписали первый договор на инвестирование денег в строительство у нотариуса, т.е. инвестируете деньги в строительство конкретной квартиры в соответствии с планом. Дополнительно, можете приобрести парковку и/или чулан. Спрашивайте у компании-застройщика, что они предлагают.\n\n4. Опционально: получаете кредит на основе договора инвестиции и Ваших документов. Приблизительно 4-5% годовых + 1% процент за недострой. Страхование заёмщика, услуги банка - около 5-6 тыс злотых.\n\n5. Оплачиваете частями стоимость квартиры в соответствии с расписанием (harmonogram), указанным в договоре. В случае кредита, сначала Вы должны банку меньше в строгом соответствии с расписанием платежей. Например, сначала это первый платёж в размере 10% стоимости квартиры и с течением времени наступает время следующих платежей. Т.е. и Ваша ипотека растёт в соответствии с выплатами.\n\n6. По окончанию строительства подписываете акт приёмки-передачи квартиры, в случае если Вы всё уже оплатили (100%). В нашем случае с момента полного расчёта по платежам прошёл приблизительно месяц и нас пригласили получить ключи. После подписания акта приёмки и получения ключей Вы можете смело начинаете ремонт, мельдоваться и даже арендовать квартиру третьим лицам.\n\n7. Застройщик информирует, когда он приготовил все документы и можно подписывать Второй и последний договор по перенесению права собственности у нотариуса. Именно, после него Вы стаёте владельцем недвижимости.\n\n8. Через три дня после подписания Договора нотариальная контора должна Вам прислать номер Numer wzmianek. Нам его забыли отправить на электронную почту, поэтому я звонил и выяснял его у нотариуса.\n\n9. Опционально (в случае ипотеки). Банк за Ваш счёт застраховывает квартиру. Стоимость страховки 1% от суммы кредита в год.\n\n10. Вы в течение 14 дней (со дня подписания договора на право собственности) регистрируете квартиру в Ужонде Миськом для начисления налогов. В течение месяца на Ваш адрес придёт письмо с информацией о необходимой оплате налогов (рассчитывается от метража). Платёж раз в год. Речь идёт о порядке 50 злотых в год.\nНам ровно через месяц пришло письмо с конкретной суммой платежа.\n\n11. Все платежи за квартиру вместе с выставленными фактурами VAT нужно распечатать и сохранить в случае вопросов от налоговой. Ещё они могут понадобиться при продаже квартиры.\n\n12. Numer wzmianek нужно сохранить. Этот номер требуется для регистрации квартиры в księga wieczysta. Иными словами, Вам нужно чтобы квартиру зарегистрировали в Земельном Кадастре. Если Вы ничего не будете предпринимать, то регистрационный номер Вам придёт почтой в течение 4-6 месяцев. \n\nКогда Вы получите этот номер и предоставите эту информацию в банк, то тогда один дополнительный процент за не дострой с Вас снимут. В Ваших интересах ускорить процесс.\n\nКстати, без этого кадастрового номера Вам квартиру не продать.', 2, '2016-05-14 21:29:16', 'post_image-80.jpeg', 138);
INSERT INTO `posts` (`id`, `title`, `content`, `author_id`, `date`, `image`, `views`) VALUES
(71, 'Как проверить застройщика, при покупке квартиры в новостройке?', 'Анализ рынка недвижимости Украины показывает: сейчас насчитывается 108 проблемных жилых строек. Люди, вложившие деньги в покупку квартир, не могут заселиться годами. Их тысячи. Нередко они откладывали покупку долгожданных метров последние накопления.\n\nКак проверить застройщика: вопросы надо задавать, чтобы избежать неприятностей при выборе нового жилья.\n\nШаг первый - мониторинг сайтов и форумов:\nПрежде всего, проверьте, не содержат списки проблемных строек понравился вам дом. Сайт Ассоциации пострадавших инвесторов приводит данные о любых проблемах объектов, а также о застройщиков, которые уже отличились небрежностью.\nТакие сайты отмечают проекты по уже выявленным проблемами, с очень высоким уровнем риска. Правда, расслабляться рано, если ваш объект там отсутствует.\n\"Нет универсального рецепта, который гарантирует проверку застройщика на\" благонадежность \". К тому же, сомневаюсь, что можно себя обезопасить полностью. Риски при инвестировании в новостройки у нас пока остаются в отличие от развитых рынков недвижимости \".\n\nШаг два - проверки риелторов:\n- Обратиться к профессиональным риелторам, которые \"в рынке\" новостроек, могут провести аудит объекта;\n- Обратиться к профессиональному юристу по недвижимости;\n- Самостоятельно собрать, проверить информацию о застройщике, ее партнеров включая финансовые организации, обслуживающие проект.\n\"Можно гарантировать отсутствие проблем, только если вы покупаете у застройщика квартиру с уже сданного в эксплуатацию дома. Здесь рисков нет. Но такие квартиры существенно дороже, чем при инвестиции на самом начальном этапе (уровень котлована). Чтобы просчитать степень риска, лучше, проверяя застройщика, заказать консультацию юриста \".\nТакой анализ рисков юристом обойдется от $ 300 до $ 800. Сумма зависит не от формата объекта или его класса, а от прозрачности работы застройщика.\n\"Иногда юрист успевает за день подготовить консультацию, но бывает, что поиск разрешительной документации занимает недели. Обычно чем больше тайн вокруг новостройки, тем чаще покупатели, заплатив консультацию, решают все же подыскивать жилье с вторичного рынка \".\n\nШаг третий - проанализировать строительство, проверить репутацию:\n\nДаю общие рекомендации тем покупателям, которые приняли решение самостоятельно, без помощи профессиональных экспертов, купить квартиру у застройщика.\n\"Представьте ситуацию, что строительство остановилось. Попробуйте понять, какие факторы могли бы привести к такому развитию событий, а также оценить их достоверность. Проанализируйте сколько, какие именно объекты застройщика были построены, введены в эксплуатацию девелопером. Насколько прозрачна предлагаемая финансовая структура сделки. Оцените динамику. Ход возведения объекта заявленному плану. Проверьте с помощью интернет-ресурсов (форумов инвесторов, профильных сайтов) репутацию застройщика \".\nРекомендую обратить внимание на упоминания о компании, ее первых лиц прессой. \"Используйте интернет, поищите информацию о застройщике, особенно - о судебных спорах. Это очень поможет понять, насколько чистая его репутация \".\n\nЧто нужно спрашивать у застройщика, решив его проверить:\nЕсли же вы сами решили разобраться, уже выбрали активно строится (по фотомониторингу) дом, юристы советуют ставить несколько обязательных вопросов.\n\n1) Чья земля, каково ее назначение. Имеет застройщик документы, подтверждающие права на участок (решение совета / распоряжение администрации). Есть государственный акт / свидетельство о праве собственности / договор аренды или суперфиция.\n\"Нужно проверить срок договора, целевое, функциональное назначение земельного участка. Если планируете покупать квартиру, а контракт содержит пункт, на этом участке должны строить стадион или офис - это неоправданный риск \".\n К сожалению, вопрос функционального назначения - достаточно рисковый. Распространенная ситуация, когда участки выделялись десять лет назад решением местных советов для строительства офисной недвижимости, но требования рынка за это время изменились - девелопер решил строить жилье. Однако местные советы не спешат проводить через заседание совета решения об изменении назначения участка. Даже великолепная команда архитекторов со строителями, беспроблемное финансирование не смогут помочь начать эксплуатацию такого дома. Как результат - жилой комплекс достроен, но инвестор въехать не сможет до достижения компромисса с местными властями.\n\n2) Разрешительные документы. Проверяя застройщика, обязательно требуйте проект, декларацию или разрешение строительства (декларация - для объектов 1-3 категории, разрешение - 4-5 категории). Соответствует ли проект градостроительным условиям, ограничениям застройки земельного участка (не нарушает строится недвижимость условия, которые ей ставит архитектура города).\nКто проектировал дом: проверить наличие сертификата в проектной организации, квалификационные аттестаты у архитекторов, конструкторов, инженеров.\n\"Обратите внимание на количество этажей будущего дома. Если планируется строительство десятиэтажного дома, а вам предлагают квартиру с 18 одного этажа - это \"очень неправильный мед\". У него гарантированно будут проблемы с вводом в эксплуатацию \".\n\n3) Кто финансирует строительство проверьте рейтинг надежности связанного банка (публичная информация). Изучите схему привлечения средств физлиц.\nУ нас разрешены четыре механизма: через Фонд финансирования строительства (ФФС), фонды операций с недвижимостью (ФОН), институты совместного инвестирования или через выпуск целевых облигаций. Правда, единственное, что в своей гарантируется, - собранные у инвесторов средства пойдут именно на строительство.\n\"Ни один из этих механизмов не предусматривает возможности возврата инвестиции по требованию до окончания строительства, тем более - своевременности сдачи дома\".\nОднако, по оценкам экспертов, чаще всего используют еще одну схему - продажа имущественных прав. Этот вариант не гарантирует также защиту от того, что одну и ту же квартиру продадут нескольким инвесторам. Судами подобные договоры не признаются гарантируют получение квартиры даже при вводе объекта в эксплуатацию.', 2, '2016-08-03 22:09:46', 'post_image-82.jpeg', 142),
(72, 'Как продать недвижимость быстро и выгодно в условиях кризиса', 'На падающем рынке недвижимости выигрывает тот, кто даст скидку больше.\nКогда цены на недвижимость снижаются в течение продолжительного времени, выигрывает тот продавец, который первым предоставит покупателю адекватную скидку.\nУмеренная щедрость поможет собрать оставшийся на рынке спрос и в итоге получить прибыль, а упрямство лишь увеличит потери.\n\nСила привычки!\nУкраинский рынок недвижимости привык существовать в условиях роста цен: с 1991 г. стоимость квадратного метра практически непрерывно увеличивалась. Да, бывали кризисы, но, до недавнего времени, коррекция всегда быстро сменялась ростом.\nВ результате выросло целое поколение, воспринимающее рост цен на недвижимость как некий закон мироздания. Такие люди, выступая в качестве продавцов на рынке – как первичном, так и вторичном, - прекрасно знают, что делать, когда жилье дорожает. Но сейчас, когда цены смотрят вниз, они нередко занимают иррациональную позицию из серии «лучше умру, но не продам дешевле, чем купил» или «лучше разорюсь, чем снижу цену». Однако в итоге такая стратегия ведет к гораздо большим потерям, чем грамотное снижение цен.\n\nЗаплатить 20% банку или покупателю?\nНаряду с падением спроса на жилье из-за общего снижения платежеспособности населения, главная беда строительных компаний в настоящее время – это крайне дорогое кредитование. Мало кому из девелоперов, не имеющих широких и прочных связей в банковском сообществе, удается взять кредит дешевле, чем под 17-20% годовых. Да и вообще получить проектное финансирование застройщики сейчас почитают за счастье.\nАльтернативой дорогим банковским предложениям являются бесплатные деньги инвесторов. Поэтому застройщики фактически стоят перед выбором: продавать медленно и печально, выплачивая бешеные проценты банку и неся другие расходы по проекту, но держать цены или все-таки согласиться на хорошую скидку и продать быстро, сэкономив на обслуживании кредита, платежах за аренду земли, накладных расходах по содержанию компании. Как правило, второй вариант оказывается куда выгоднее первого.\nПри таких банковских процентах можно предлагать покупателю не символические скидки, а те же 20%, которые иначе все равно придется отдать банку. Особенно если речь идет о большом объекте, где необходимо поддерживать высокие темпы продаж. Причем не обязательно распродавать с большим дисконтом все квартиры. Если застройщик уже собрал достаточно средств для бесперебойного финансирования стройки, то оставшиеся объемы можно и придержать.\nВообще в мире есть немало примеров регулярных распродаж даже очень дорогих товаров со значительными скидками. Например, новый автомобиль прошлого и позапрошлого годов выпуска можно купить на 20-30% дешевле последней модели - дилерам и автопроизводителям выгоднее снизить цену, чем продолжать хранить товар. Конечно, квартиры «морально» устаревают медленнее, чем машины, но и стоимость содержания непроданной недвижимости значительно выше.\n\nУпущенная прибыль!\nНемалую долю продавцов квартир на вторичном рынке составляют инвесторы, которые не хотят расставаться со своей собственностью по цене меньше той, которая сложилась в какой-то момент на растущем рынке. Из-за этого разрыв между пожеланиями продавцов и возможностями покупателей в настоящее время достигает 30-40, а то и 50%, что, естественно, приводит к резкому сокращению числа сделок.\nТаким образом, отказываясь пойти навстречу покупателям, продавцы-инвесторы просто замораживают собственные деньги, которые можно было бы вложить в более выгодный актив. Хотя бы на депозит положить – доход по крупным вкладам в госбанках в настоящее время составляет примерно 10%. То есть продавец квартиры может согласиться скинуть 10%, достаточно быстро продать недвижимость и через год полностью возместить скидку или те же 12 месяцев упрямо ждать щедрого покупателя и, так и не дождавшись, все равно снизить цену, причем уже больше, чем на 10%, так как цены на рынке падают. Например, еще в начале года для оперативной продажи недвижимости достаточно было 3-5-процентной скидки, а банки предлагали 15% годовых по депозитам…\nКонечно, в надежде на бурный рост цен на жилье в будущем можно продолжать стоять на своем и дальше, но когда оправдаются эти надежды и оправдаются ли вообще – вопрос философский. Признаки разворота рынка пока не просматриваются даже на горизонте. Зато упущенная прибыль от потенциальных инвестиций в другие активы абсолютно гарантирована. И этот убыток может быть очень значительным, ведь банковский депозит – это самый низкорисковый, но и самый низкодоходный финансовый инструмент.\n\nУлучшить жилищные условия!\nТе, кто продают квартиру для того, чтобы получить деньги на покупку новой, по сути, совершают обмен. Таким людям совершенно не нужно бояться продавать свое жилье со скидкой, потому что новое они также купят с дисконтом. Причем если речь идет о приобретении более дорогой квартиры, то экономия на такой покупке в абсолютном выражении превысит потери от продажи своей недвижимости с дисконтом.\nЧасто бывает так, что люди упускают интересные варианты на рынке новостроек, так как не могут продать имеющуюся квартиру за желаемую цену, по максимуму. В результате, не соглашаясь скинуть 5%, продавцы теряют квартиру, экономия при покупки которой с лихвой компенсировала бы их потери.\"', 2, '2016-08-18 15:11:51', 'post_image-84.jpeg', 102),
(73, 'Простая инструкция для желающих инвестировать в доходную недвижимость за рубежом!', 'Все знают, что самое важное правило при инвестициях — не класть все яйца в одну корзину. Однако не меньшее значение имеют ответы на вопросы о том, куда вкладывать и в какой пропорции распределять средства, чтобы получить оптимальный баланс доходности и риска. В контексте инвестиций в недвижимость за рубежом мой совет — распределяйте капитал по двум «корзинам» с соотношением 70/30 %.\n\nПервая «корзина»: для сохранения капитала!\nБольшую часть средств — 70 % — рекомендую направить на вложения в низкорисковые проекты. Стратегия сохранения капитала предполагает ориентировочную доходность 4−5 % годовых, которая должна быть выше аннуитета (проценты по кредиту плюс платежи по телу кредита) ипотечного кредитования, чтобы денежный поток не стал отрицательным. Задача инвестора в этом случае — сохранить капитал и обогнать инфляцию на первом этапе, а также создать семейный фонд благосостояния в долгосрочной перспективе.\n Для таких инвестиций подходит жилая недвижимость в крупных городах и торговые объекты на оживлённых пешеходных улицах. Но у обоих вариантов доходность на сегодняшнем рынке низкая — порядка 2−3 %. Помимо этого, стоимость квартир в хорошем районе (как для инвесторов, так и для арендаторов) может быть высокой, а цены на торговую недвижимость ещё выше. Компромиссный вариант — микроапартаменты. Население европейских городов растёт на 1,5 % ежегодно, и в основном это происходит за счёт людей, переезжающих из небольших населённых пунктов в поисках работы. Именно для них в Германии строятся квартиры площадью 20−30 кв. м, в которых есть всё необходимое — санузел, мини-кухня, стол и кровать. Люди арендуют такое жилье в течение трудовой недели, а на выходные уезжают в свои дома в регионах. Также небольшие квартиры востребованы у студентов и молодых специалистов, которые пока не обзавелись семьёй.\n Микроапартаменты — одни из самых интересных объектов для инвестиций в недвижимость. С одной стороны, за счёт микроформата жилье этого типа стоит дёшево для арендатора (около 400 евро в месяц), с другой стороны — даёт больше арендной выручки на квадратный метр для владельца (доходность — порядка 4−5 %). При этом ликвидность микроапартаментов будет только увеличиваться по мере роста городского населения. Помимо этого, риски инвестиций в такие объекты минимальны. Во-первых, нет проблем с выселением недобросовестных съёмщиков, как при традиционной долгосрочной аренде — контракты подписываются на 3−6 месяцев. Во-вторых, жильцы платят страховые депозиты на случай причинения ущерба или при наличии задолженностей. Инвестору необязательно погружаться в арендный менеджмент: работа со съёмщиками, решение их проблем, обслуживание недвижимости и даже зачастую ремонт — всё это лежит на управляющей компании.\n Для инвестиций в микроапартаменты лучше всего подходит Германия, поскольку при вложениях в простой арендный бизнес важна стоимость финансирования, а кредиты в этой стране — одни из самых доступных в мире. Инвестор-нерезидент может получить ипотеку в размере 50 % от стоимости объекта под менее чем 2 % годовых (фиксированная ставка) на 10−20 лет. Дешёвое финансирование действует как рычаг, увеличивая доходность на вложенный капитал. Проценты по кредиту при этом идут в расход и снижают налоговую базу.\n Без сомнений, для сохранения средств также подходят и другие развитые страны: Австрия, Великобритания, США, Швейцария. Однако в Великобритании и США дорогое финансирование для нерезидентов, а в Австрии и Швейцарии хотя и дешёвые кредиты, но сложнее найти качественные объекты с доходностью 4−5 %, так как страны маленькие и местные инвесторы очень расторопны и быстро раскупают лучшее. Помимо этого, в этих двух странах действуют территориальные ограничения для иностранных покупателей недвижимости. Рынок Германии больше, и шансы найти хороший объект в этой стране выше. Также рынок Австрии и Швейцарии в последние годы растёт медленнее немецкого.\n\nВторая «корзина»: для заработка!\nДля второй «корзины» рекомендую предусмотреть 30 % капитала, который пойдёт на инвестиции в более сложные проекты добавленной стоимости (Added Value). Эту стратегию можно описать тремя словами: купи, почини, продай. Суть схемы в том, что инвестор покупает жилой, офисный или гостиничный объект в плохом состоянии, делает ремонт, за счёт чего повышается стоимость недвижимости, и далее объект продаётся по более высокой цене.\n Инвестиции в Added Value — более сложный бизнес по сравнению с арендным, поскольку есть риски, связанные с возможным превышением сметы, трудностями при оформлении разрешений. Помимо этого, цена покупки может быть завышена, а цена продажи — занижена, или объект может продаваться долго. К тому же инвестор или его команда должны активно участвовать в проекте и иметь квалификацию в строительном бизнесе. Это более рискованный вариант инвестиций в недвижимость, но и более доходный: на редевелопменте можно заработать 12−20 % на вложенный капитал. Ещё одно преимущество такой инвестиции заключается в том, что за счёт необходимости впоследствии сделать ремонт можно получить скидку с цены покупки.\n При инвестициях в проекты Added Value увеличить доходность можно следующим образом: \n подобрать профессиональную команду, которая сможет эффективно управлять процессом на месте (такие проекты почти невозможно реализовать удалённо, без местного партнёра); \n инвестировать в рынки с потенциалом роста цен; вложить деньги в ликвидные объекты, чтобы по окончании проекта их можно было быстро и выгодно продать;\n правильно структурировать сделку для оптимизации налогов и увеличения доходности (актуально также для стратегии сохранения капитала): например, если оформить сделку на компанию, то зачастую можно избежать уплаты налога на переход права собственности;\n взять ипотечный кредит: банковское финансирование снижает потребность в собственном капитале, создаёт кредитный рычаг и увеличивает доходность. Сегодня ставка по ипотечным кредитам в Европе составляет 2−3 %.\n\nСегодня для инвестиций в проекты Added Value хорошо подходит Испания. Цены на недвижимость в этой стране падали в течение семи лет и начали стабилизироваться в 2014 году. Сейчас объекты в Испании стоят на 45 % дешевле по отношению к пику 2007 года, но уже начинают дорожать, поэтому, купив объект по минимальной цене, с учётом последующего роста цен, инвесторы могут заработать на продаже через несколько лет. Длительный период рецессии пройден, а значит, рынок ждёт восстановление: экономическая ситуация улучшается, потребительское доверие растёт, уровень безработицы снижается, а объёмы строительства увеличиваются и банки охотнее выдают ипотеку.\n Среди городов Испании инвестировать в проекты Added Value выгодно в Барселоне. Инвесторы всё чаще вкладывают средства в проекты редевелопмента, поскольку на рынке жилья столицы Каталонии наблюдается дефицит новостроек. Особенно перспективна покупка жилых зданий для ремонта с целью последующей перепродажи местным экспатам или для создания студенческих комплексов и апарт-отелей. Помимо этого, в Барселоне высок потенциал роста цен: за 2016 год жильё может подорожать на 7 %. Также выгодно инвестировать в проекты реконструкции в Мадриде, где не хватает новых и качественных предложений в офисном сегменте.\n\nЕсли инвестировать все 100 % средств в арендные проекты, это будет хорошим и надёжным вложением, но на краткосрочном горизонте заработать таким образом трудно. Если вложить всё в проекты с добавленной стоимостью, то риски будут слишком высокими. По моему мнению, наиболее разумным балансом для зарубежного инвестора является стратегия, при которой 70 % средств инвестируются в арендные объекты и 30 % — в редевелопмент. Это позволяет получить оптимальный баланс доходности и риска.\n\nРекомендую сначала приобрести объекты с низким риском, получить опыт покупки и управления недвижимостью за рубежом, а потом нацеливаться на более сложные проекты с добавленной стоимостью.\n\nНапример, при наличии 1 млн евро можно сформировать инвестиционный портфель, взяв ещё 1 млн в кредит, вложив 1,4 млн в покупку пакета апартаментов для сдачи в аренду, а затем направить оставшиеся 600 тыс. в проект редевелопмента. Сбалансированная доходность от таких операций будет выше 10 % годовых, при этом риски останутся низкими.', 2, '2016-08-18 15:30:01', 'post_image-85.jpeg', 140);

-- --------------------------------------------------------

--
-- Структура таблицы `units`
--

CREATE TABLE `units` (
  `id` int(11) NOT NULL,
  `title` varchar(1024) NOT NULL,
  `symbol` varchar(128) NOT NULL,
  `code` varchar(256) NOT NULL,
  `unitGroup` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `units`
--

INSERT INTO `units` (`id`, `title`, `symbol`, `code`, `unitGroup`) VALUES
(1, 'Квадратный метр', 'м²', 'М2', 2),
(2, 'Украинская гривна', '₴', 'UAH', 1),
(3, 'Российский рубль', '₽', 'RUR', 1),
(4, 'Доллар США', '$', 'USD', 1),
(5, 'Евро', '€', 'EUR', 1),
(6, 'Сотка', 'cоток', 'АР', 2);

-- --------------------------------------------------------

--
-- Структура таблицы `userGroups`
--

CREATE TABLE `userGroups` (
  `id` int(11) NOT NULL,
  `title` varchar(1024) NOT NULL,
  `access` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `userGroups`
--

INSERT INTO `userGroups` (`id`, `title`, `access`) VALUES
(1, 'Администратор', 1),
(2, 'Партнер', 2),
(3, 'Пользователь', 3);

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nickname` varchar(256) NOT NULL,
  `password` varchar(256) NOT NULL,
  `firstName` varchar(512) NOT NULL,
  `lastName` varchar(512) NOT NULL,
  `email` varchar(512) NOT NULL,
  `telephone` varchar(64) NOT NULL,
  `site` varchar(256) NOT NULL,
  `position` varchar(512) NOT NULL,
  `experience` varchar(64) NOT NULL,
  `country` varchar(512) NOT NULL,
  `userGroupId` int(11) NOT NULL DEFAULT '3',
  `dateOfBirth` datetime DEFAULT NULL,
  `dateOfRegistration` datetime NOT NULL,
  `about` varchar(8192) NOT NULL,
  `photo` varchar(512) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `users`
--

INSERT INTO `users` (`id`, `nickname`, `password`, `firstName`, `lastName`, `email`, `telephone`, `site`, `position`, `experience`, `country`, `userGroupId`, `dateOfBirth`, `dateOfRegistration`, `about`, `photo`) VALUES
(4, 'medvedbeast', '123', 'Ростислав', 'Савельев', '', '', '', '', '', '', 3, '1997-05-04 00:00:00', '2015-08-01 15:10:35', '', 'user_image-5.jpeg'),
(2, 'sanches999', '123', 'Александр', 'Ткаченко', 'sanches999@ukr.net', '+380975558486', 'http://top-real.com.ua/', 'Директор ', '23 года', 'Украина', 1, '1978-09-09 00:00:00', '2014-10-20 00:00:00', 'Информация на нашей Youtube-странице https://www.youtube.com/playlist?list=PLAOlXRWtZxRU29xUyINy7gKVCaGl-s94q\nЗанимаемся недвижимостью по всей Украине и Европе! Часть прибыли перечисляем на благотворительные фонды, а также помогаем детям сиротам, инвалидам, больным! Обращаясь к нам, Вы помогаете тем, кому нужна помощь! \n\nПредложение партнерам: Высокодоходные инвестиционные проекты в сфере недвижимости для частных и корпоративных инвесторов. Строго конфиденциально. Рентабельность-в зависимости от степени риска и напряжения- от 50 до 200 годовых. Опыт Успешной деятельности с 1994 года. \n\nПредложение клиентам: Если Вы не хотите тратить свое время на пустые звонки от незнакомых людей, продать или сдать Свою недвижимость и это все в максимально быстрое время, мы сможем быть Вам полезны. Как и чем мы можем Вам помочь: - Информация о Вашем Бизнесе, Санатории, Базе Отдыха, Отеле, Спортивном Комплексе, Фабрике, Заводе, Аграрном Комплексе, Замке, Дворце, Имении, Здании, Коттедже, Таунхаусе, Небоскребе, Доме, Даче, Квартире, Складе, Хранилище, Земельном участке, Озере, Ставке и т.д., будет размещена на нашем сайте недвижимости и еще на 100 сайтах (которые обновляются регулярно); - Вам не нужно будет самостоятельно рассылать предложение всем агентствам; - Вам будет звонить только один человек в удобное для Вас время; - Быстро и профессионально организуем процесс привлечения клиентов; - Поможем назначить правильную цену аренды, продажи; - Сведем количество «пустых» просмотров до минимума; - Грамотно проконсультируем потенциальных клиентов; - Защитим Ваши интересы, оформив юридически выверенный договор; - Проведем профессиональную фото сессию и Видео-репортаж предлагаемого объекта. Потратьте свое время с пользой положив заботы на плечи профессионалов! \n\nВыход на любые земельные участки по всей Украине! Помощь в оформлении всех видов документов, смена целевого назначения! Можем подобрать, нужный участок объект! \nНаше любимое направление: это девственная природа, безграничная территория для вложения капитала, зеленая часть территории Украины - Карпаты! Инвестиции в Карпаты – это инвестиции в своё здоровье, в здоровое будущее своих детей, возможность дышать свежим воздухом и пить чистую живую воду!\n -Мы стремимся стать ЛУЧШИМИ и помочь стать лучшими нашим ПАРТНЕРАМ! - Мы знаем, ЧТО делаем! -Мы знаем, КАК это делать! -С нами работать ПРОСТО! -С нами работать ВЫГОДНО! -С нами работать ИНТЕРЕСНО!', 'user_image-7.jpeg');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `categoryGroups`
--
ALTER TABLE `categoryGroups`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `characteristics`
--
ALTER TABLE `characteristics`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `images`
--
ALTER TABLE `images`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `offerCharacteristics`
--
ALTER TABLE `offerCharacteristics`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `offers`
--
ALTER TABLE `offers`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `paidOffers`
--
ALTER TABLE `paidOffers`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `units`
--
ALTER TABLE `units`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `userGroups`
--
ALTER TABLE `userGroups`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=205;

--
-- AUTO_INCREMENT для таблицы `categoryGroups`
--
ALTER TABLE `categoryGroups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT для таблицы `characteristics`
--
ALTER TABLE `characteristics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT для таблицы `images`
--
ALTER TABLE `images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1266;

--
-- AUTO_INCREMENT для таблицы `offerCharacteristics`
--
ALTER TABLE `offerCharacteristics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2902;

--
-- AUTO_INCREMENT для таблицы `offers`
--
ALTER TABLE `offers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=168;

--
-- AUTO_INCREMENT для таблицы `posts`
--
ALTER TABLE `posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=74;

--
-- AUTO_INCREMENT для таблицы `units`
--
ALTER TABLE `units`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT для таблицы `userGroups`
--
ALTER TABLE `userGroups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
