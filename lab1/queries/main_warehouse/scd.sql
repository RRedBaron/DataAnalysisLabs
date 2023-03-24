use winter_olympics_main;

drop procedure if exists slow_change_countries;

delimiter //
create procedure slow_change_countries(old_name varchar(255), old_ioc varchar(5), new_name varchar(255),
                                       new_ioc varchar(255))
begin
    declare old_country_id int default null;

    select distinct id
    into old_country_id
    from country_dim
    where country = old_name and ioc = old_ioc;

    if old_name is null then
        signal sqlstate '45000' set message_text = 'Such country does not exist';
    else
        insert into country_dim (country, IOC, source_id, start_date)
            value (new_name, new_ioc, old_country_id, CURRENT_DATE);

        update country_dim
        set end_date = CURRENT_DATE
        where old_country_id = id;
    end if;
end //
delimiter ;

call slow_change_countries('Russia', 'RUS', 'Moskovia', 'MSK');