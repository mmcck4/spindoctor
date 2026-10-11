function plot_signal_btpde_mf(setup, signal_allcmpts, signal_mf_allcmpts, signal_mfga_allcmpts)
%PLOT_SIGNAL_BTPDE_MF Plot BTPDE, MF and MFGA signal.

markervec = {"o"; "o"; "+"; "d"; "s"; "*"};
colorvec = {"r"; "b"; "k"; "c"; "g"; "m"};

bvalues = setup.gradient.bvalues;
nsequence = size(bvalues, 2);

figure;
hold on

%% BTPDE
iplot = 0;
for iseq = 1:nsequence
    yvec = real(signal_allcmpts(:, iseq));
    bvec = bvalues(:, iseq);
    h = plot(bvec, log10(yvec), ...
    [colorvec{mod(iseq - 1, 6) + 1}, markervec{1}]);

    set(h, "MarkerSize", 9, "LineWidth", 1);
    iplot = iplot + 1;
    legend_vec{iplot} = sprintf("BTPDE Experi %d", iseq);
end
legend(legend_vec{1:iplot});
legend("Location", "southwest");


%% MF
markervec(1) = "-";
markervec(2) = "-";
markervec(3) = "--";
markervec(4) = "d";
markervec(5) = "s";
markervec(6) = "x";
for iseq = 1:nsequence
    yvec = real(signal_mf_allcmpts(:, iseq));
    bvec = bvalues(:, iseq);
    h = plot(bvec, log10(yvec), ...
    [colorvec{mod(iseq - 1, 6) + 1}, markervec{6}]);
    set(h, "MarkerSize", 9, "LineWidth", 1);

    iplot = iplot + 1;
    legend_vec{iplot} = sprintf("MF Experi %d", iseq);
end
legend(legend_vec{1:iplot});
legend("Location", "southwest");

%% MFGA
markervec(1) = "--";
markervec(2) = "--";
markervec(3) = "--";
markervec(4) = "d";
markervec(5) = "s";
markervec(6) = "*";
for iseq = 1:nsequence
    yvec = real(signal_mfga_allcmpts(:, iseq));
    bvec = bvalues(:, iseq);
    h = plot(bvec, log10(yvec), ...
    [colorvec{mod(iseq - 1, 6) + 1}, markervec{mod(iseq - 1, 6) + 1}]);
    set(h, "LineWidth", 1);
    iplot = iplot + 1;
    legend_vec{iplot} = sprintf("MFGA Experi %d", iseq);
end

%%
lgd = legend(legend_vec(1:iplot));
set(lgd, "location", "southwest");
set(gca, "FontSize", 12)
grid on
title("BTPDE, MF and MFGA signals");
