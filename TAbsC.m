function T = TAbsC(inv_T,inverse_name);


switch inverse_name
    case 'fft2D'
        
        T = inv_T * size(inv_T,1) * size(inv_T,2);
    case {'fft1D','hfft'}
        T = inv_T * length(inv_T); 
        %T = inv_T;
    otherwise
    T=inv_T;        
end
