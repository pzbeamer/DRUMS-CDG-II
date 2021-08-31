function [time_in_seconds] = celltime_to_seconds(cell_with_string_time)
    t = cell_with_string_time{1};
    
    if sum(t == '.') == 0 %Make sure there is a .0 at the end
        t = strcat(t,'.0');
    end
    
    len = length(t);
    
    if len >= 3
        if t(end-2) == '.' %Gaurd against the auto formating of .00 instead of .0
            t = t(1:end-1);
        end
    end
    
    if sum(t == '.') ~=0 && sum(t == ':') ~=0
        c_ind = find(t==':');
        p_ind = find(t=='.');
        if p_ind - c_ind == 2 %Gaurd against 34:6.0 instead of 34:06.0
            t = strcat(t(1:c_ind),'0',t(p_ind-1:end));
        end 
    end
    
    
        
            
    
    
    if len >= 9 %Hours max
        hour = str2double(t(1:end-8));
        min = str2double(t(end-6:end-5));
        second = str2double(t(end-3:end));
    elseif len >= 6 %Minutes max
        hour = 0;
        min = str2double(t(1:end-5));
        second = str2double(t(end-3:end));
    elseif len >= 3 %Seconds max
        hour = 0;
        min = 0;
        second = str2double(t(1:end));
    end
    
    time_in_seconds = hour*60*60 + min*60 + second;
    

end