function presentation_format(option)

if strcmp(option, 'paper')

    reset(groot);
    reset(gca);
    set(groot,'defaultTextFontName','Times')
    set(groot,{'DefaultAxesXColor',...
        'DefaultAxesYColor','DefaultAxesZColor'}, {'k','k','k'})
    set(gca,'FontSize',18)
    xlabel("xlabel",'FontSize',24,...
        'FontWeight','bold','FontName','Times')
    ylabel("ylabel",'FontSize',24,...
        'FontWeight','bold','FontName','Times')
    title("Title",'FontSize',24,...
        'FontWeight','bold','FontName','Times')
    grid on;
    
elseif strcmp(option, 'slides')
    reset(groot);
    reset(gca);
    % for x
    set(gca,'xcolor','w') 
    % for y
    set(gca,'ycolor','w') 
    % for z
    set(gca,'zcolor','w')
    set(groot,{'DefaultAxesXColor',...
        'DefaultAxesYColor','DefaultAxesZColor'}, {'w','w','w'})
    set(gca,'FontSize',18)
    xlabel("xlabel",'FontSize',24,...
        'FontWeight','bold','FontName','Calibri')
    ylabel("ylabel",'FontSize',24,...
        'FontWeight','bold','FontName','Calibri')
    title("Title",'FontSize',24,...
        'FontWeight','bold','FontName','Calibri')
    grid on;
    set(gca, 'GridColor', [0.2, 0.2, 0.2]);
    
else
    error("option must be 'paper' or 'slides'!");
end

end