# Launchers read res/xml/*.xml and resolve drawables by name across process
# boundaries, so the R class entries for them must survive minification.
-keepclassmembers class com.hatsyrei.mikuiconpack.R$drawable { *; }
-keepclassmembers class com.hatsyrei.mikuiconpack.R$xml { *; }
