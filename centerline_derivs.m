function mix_zone=centerline_derivs(temp_distribution)
    
    vert_pos=temp_distribution.position_y;
    
    distr=temp_distribution.value.cal;
    distr_size=numel(distr);
    distr_norm=(distr-min(distr))/max(distr-min(distr));
    
    cut_off=0.1;  %by how much temperature can differ and still qualify
    
%     steam_zone=distr_norm>=(1-cut_off);
%     gas_zone=distr_norm<=cut_off;
    mixing_zone=distr_norm<(1-cut_off) & distr_norm>cut_off;
    positions=find(mixing_zone);
  
    if ~isempty(positions)
        if (positions(end)+1)<=distr_size && (positions(1)-1)>0
            mix_zone.length_max=vert_pos(positions(end)+1)-vert_pos(positions(1)-1);
            mix_zone.length_min=vert_pos(positions(end))-vert_pos(positions(1));
            mix_zone.length_error=(mix_zone.length_max-mix_zone.length_min)/2;
            mix_zone.start=vert_pos(positions(1)-1);
            mix_zone.end=vert_pos(positions(end)+1);
            mix_zone.start_error=(mix_zone.start-vert_pos(positions(1)))/2;
        else
            mix_zone.length_max=NaN;
            mix_zone.start=NaN;
            mix_zone.start_error=NaN;
            mix_zone.length_error=NaN;
        end
        
    else
        mix_zone.length_max=NaN;
        mix_zone.start=NaN;
        mix_zone.start_error=NaN;
        mix_zone.length_error=NaN;
    end
    
    distr_vars=zeros(1,distr_size);
    
    for n=1:distr_size
        distr_vars(n)=var(temp_distribution.var(:,n));
    end
    
%     distr_vars_norm=(distr_vars-min(distr_vars))/max(distr_vars-min(distr_vars));
%     try
%         figure
%         plot(vert_pos,distr)
%         hold on
%         limits=ylim;
%         plot([mix_zone.start,mix_zone.start],[limits(1),limits(2)],'g')
%         plot([mix_zone.end,mix_zone.end],[limits(1),limits(2)],'r')
%     catch
%     end
%     
%     try
%         figure
%         plot(vert_pos,distr_vars)
%         hold on
%         limits=ylim;
%         plot([mix_zone.start,mix_zone.start],[limits(1),limits(2)],'g')
%         plot([mix_zone.end,mix_zone.end],[limits(1),limits(2)],'r')
%     catch
%     end
    
end