# home-manager/utilities/default-apps.nix
# XDG default application associations
{...}: {
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "inode/directory" = ["thunar.desktop"];

    # Word / Writer (.doc .docx .docm .dotx .dotm)
    "application/msword"                                                         = ["writer.desktop"];
    "application/vnd.ms-word.document.macroEnabled.12"                          = ["writer.desktop"];
    "application/vnd.ms-word.template.macroEnabled.12"                          = ["writer.desktop"];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document"   = ["writer.desktop"];
    "application/vnd.openxmlformats-officedocument.wordprocessingml.template"   = ["writer.desktop"];

    # Excel / Calc (.xls .xlsx .xlsm .xltx .xltm)
    "application/vnd.ms-excel"                                                   = ["calc.desktop"];
    "application/vnd.ms-excel.sheet.macroEnabled.12"                            = ["calc.desktop"];
    "application/vnd.ms-excel.template.macroEnabled.12"                         = ["calc.desktop"];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"         = ["calc.desktop"];
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template"      = ["calc.desktop"];

    # Jupyter Notebooks (.ipynb)
    "application/x-ipynb+json" = ["jupyterlab.desktop"];

    # PowerPoint / Impress (.ppt .pptx .pptm .potx .potm .ppsx .ppsm)
    "application/vnd.ms-powerpoint"                                              = ["impress.desktop"];
    "application/vnd.ms-powerpoint.presentation.macroEnabled.12"                = ["impress.desktop"];
    "application/vnd.ms-powerpoint.template.macroEnabled.12"                    = ["impress.desktop"];
    "application/vnd.ms-powerpoint.slideshow.macroEnabled.12"                   = ["impress.desktop"];
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = ["impress.desktop"];
    "application/vnd.openxmlformats-officedocument.presentationml.template"     = ["impress.desktop"];
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow"    = ["impress.desktop"];
  };
}
