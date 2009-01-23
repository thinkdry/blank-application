 function showhide(id){
                    if (document.getElementById){
                    obj = document.getElementById(id);
                    if (obj.style.display == "none"){
                    obj.style.display = "";
                    }
                    else 
                    {
                        obj.style.display = "none";
                     }
                    }
                }    
                

var file1="";
function LimitAttach(form, file, type) {
if(type=="audio")
extArray = new Array(".wav",".mp3");
if(type=="video")
extArray = new Array(".mov", ".mpeg", ".mpg", ".mp4", ".qt", ".flv");
if(type=="image")
extArray = new Array(".gif", ".jpg", ".jpeg", ".png");
allowSubmit = false;
if(file1==file) return;
if (!file) return;
while (file.indexOf("\\") != -1)
file = file.slice(file.indexOf("\\") + 1);
ext = file.slice(file.indexOf(".")).toLowerCase();
for (var i = 0; i < extArray.length; i++) {
if (extArray[i] == ext) { allowSubmit = true; break; }
}
if (!allowSubmit)
alert("Please only upload files that end in types:  " 
+ (extArray.join("  ")) + "\nPlease select a new "
+ "file to upload and submit again.");
file1=file
}
