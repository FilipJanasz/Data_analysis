function PT100_error_total_abs=error_PT100
        % due to PT100
        PT100_error_abs=0.03;               % [K] absolute http://www.priggen.com/index.php?page=shop.product_details&flypage=flypage-ask.tpl&product_id=48&category_id=10&manufacturer_id=11&option=com_virtuemart&Itemid=44&lang=en
        % due to Omega PT-104A (PT100)
        DAS_PT100_err_abs=0.01;  %[K]
        %total PT100
        PT100_error_total_abs=sqrt(PT100_error_abs^2+DAS_PT100_err_abs^2);    %[K]
end