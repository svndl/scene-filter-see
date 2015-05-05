function plot_sceneScalesDecomp(scene, save_path)
                  
    f = figure('Name',scene.name, 'visible', 'on', 'Interpreter', 'none');           
    versions = {'Original','Enhanced', 'Degraded'};
    markers = {'o', '*', '+'};
    color_opts = {'-.r', '-.b', '-.y'};
    title(['Scale decomposition ' scene.name]); hold on
    xlabel('Scale'); hold on;
    ylabel('Luminance-depth correlation'); hold on;
                 
    plot(scene.orig.ld_corr, color_opts{1}, 'Marker', markers{1}, 'Linewidth', 2); hold on;
    plot(scene.enh.ld_corr, color_opts{2}, 'Marker', markers{2}, 'Linewidth', 2); hold on;
    plot(scene.deg.ld_corr, color_opts{3}, 'Marker', markers{3}, 'Linewidth', 2); hold on;
        
    legend(versions{:});
    try
        export_fig(f, fullfile(save_path, [scene.name '.pdf']), '-transparent');
    catch
        saveas(f, fullpath(save_path, [scene.name '.pdf']));
    end
    close(f);                   
end