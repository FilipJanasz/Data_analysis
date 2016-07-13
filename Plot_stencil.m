function [ FontSize,FontName ] = Plot_stencil( ws,hs )

disp_scale = 1;

FontSize = 10.5*disp_scale;
FontName = 'Calibri';

axes_width = 13.5*disp_scale;
axes_height = 3.4*disp_scale;

left_margin = 2.4*disp_scale;
right_margin = 0.3*disp_scale;
lower_margin = 2*disp_scale;
upper_margin = 0.2*disp_scale;
vert_separation = 1*disp_scale;

figure_width = left_margin + ws*axes_width + right_margin;
figure_height = lower_margin + hs*axes_height + 5*vert_separation + upper_margin;

axes_width = axes_width/figure_width;
axes_height = axes_height/figure_height;
left_margin = left_margin/figure_width;
right_margin = right_margin/figure_width;
lower_margin = lower_margin/figure_height;
upper_margin = upper_margin/figure_height;
vert_separation = vert_separation/figure_height;

%%  Create figure
figure(); clf;
set(gcf, 'units', 'centimeters', 'pos', [0.5, 1.2, figure_width, figure_height]);
set(gcf, 'PaperPosition', [(21-figure_width/disp_scale)/2 (29.7-figure_height/disp_scale)/2 figure_width/disp_scale figure_height]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'Position', [5 1.2 figure_width figure_height]);
set(gcf, 'color', [1 1 1]);
set(gca, 'color', [1 1 1]);
set(gcf, 'Renderer', 'painters');


end

