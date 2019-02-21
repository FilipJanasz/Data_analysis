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
    
    
    %if there are locations found
    if ~isempty(positions) && (positions(end)+1)<=distr_size %&& (positions(1)-1)>0)
        
        %values
        mix_zone.length_max=vert_pos(positions(end)+1)-vert_pos(positions(1)-1);
        mix_zone.length_min=vert_pos(positions(end))-vert_pos(positions(1));
        mix_zone.start=vert_pos(positions(1)-1);
        mix_zone.end=vert_pos(positions(end)+1);

        %errors            
        mix_zone.length_error=(mix_zone.length_max-mix_zone.length_min)/2;
        mix_zone.start_error=(mix_zone.start-vert_pos(positions(1)))/2;
        mix_zone.end_error= mix_zone.start_error;
 
    else
        mix_zone.length_max=NaN;
        mix_zone.start=NaN;
        mix_zone.end=NaN;
        mix_zone.start_error=NaN;
        mix_zone.end_error=NaN;
        mix_zone.length_error=NaN;
    end
    
    %interpolate data on a tighter grid
    vertPosInt=10:10:vert_pos(end);
    distrNormInterp=interp1(vert_pos,distr_norm,vertPosInt);
    mixing_zoneInt=distrNormInterp<(1-cut_off) & distrNormInterp>cut_off;
    posInterp=find(mixing_zoneInt);
    distrInt_size=numel(vertPosInt);
    
    %if there are locations found with interpolation
    if ~isempty(posInterp) && (posInterp(end)+1)<=distrInt_size %&& (posInterp(1)-1)>0)
           
            %with 1D interpolation
            mix_zone.lengthInt_max=vertPosInt(posInterp(end)+1)-vertPosInt(posInterp(1)-1);
            mix_zone.lengthInt_min=vertPosInt(posInterp(end))-vertPosInt(posInterp(1));     
            mix_zone.startInt=vertPosInt(posInterp(1)-1);
            mix_zone.endInt=vertPosInt(posInterp(end)+1);
            
            %errors
%             mix_zone.lengthInt_error=(mix_zone.lengthInt_max-mix_zone.lengthInt_min)/2;
            mix_zone.lengthInt_error=50;
%             mix_zone.startInt_error=(mix_zone.startInt-vertPosInt(posInterp(1)))/2;
            mix_zone.startInt_error=50;
            mix_zone.endInt_error= mix_zone.startInt_error;
 
    else

        %with 1D interpolation
        mix_zone.lengthInt_max=NaN;
        mix_zone.startInt=NaN;
        mix_zone.endInt=NaN;
        mix_zone.startInt_error=NaN;
        mix_zone.endInt_error=NaN;
        mix_zone.lengthInt_error=NaN;
    end
    
%     distr_vars=zeros(1,distr_size);
%     
%     for n=1:distr_size
%         distr_vars(n)=var(temp_distribution.var(:,n));
%     end
    
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