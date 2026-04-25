function inverse_name = IA(inverse_name_initial,array_type)


if strcmp('auto',inverse_name_initial)  
    if (ischar(array_type)==0)  
        switch size(array_type,1)  
            case 1
                inverse_name = 'fft1D';
            case 2
                inverse_name = 'fft2D';
        end
    else
        
        switch array_type    
            case 'mrla'
                inverse_name = 'fft1D';
            case 'ula'
                inverse_name = 'fft1D';
            case 'Y_shape'
                inverse_name = 'hfft';
            case 'T_shape'
                inverse_name = 'fft2D';
            case 'O_shape'
                inverse_name = 'dftcircle';
            case 'cross_shape'
                inverse_name = 'fft2D';
        end
    end
else
    
    inverse_name = inverse_name_initial;
end

        