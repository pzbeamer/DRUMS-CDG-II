%Mette's psuedo code
function Run_DriverBasic

for i = 1:1
    call_flag  = 'opt';
    if i == 1 
        data = patient1;
    elseif i == 2
       data = patient2; 
    elseif i == 2
       data = patient2;   
    elseif i == 3
       data = patient3;   
    elseif i == 4
       data = patient4; 
    elseif i == 5
       data = patient5; 
    elseif i == 6
       data = patient6; 
    elseif i == 7
       data = patient8; 
    elseif i == 8
       data = patient11;  
    else
        data = patient20;
    end
    
    switch call_flag
       % no atrium
       case 'noAtr'; DriverBasic_noAtrium(data);
       % inductor
       case 'ind';   DriverBasic_Ind(data);
       % standard model
       case 'model'; DriverBasic(data,i);
       % optimization
       case 'opt';  DriverBasic_opt(data);
       % sensitivity analysis   
      case 'sens';  
      Sens{i} = DriverBasic_sens(data);
    end
end;