/* 
 * Generate index.html
 */
function generate(template, state) {

    $.each( state, function( key, value ) {
        $('#' + key).val(value);
    });


    $( INPUTS ).each(function() {
        var id = $( this ).attr('id');
        var value = $( this ).val();
        if ($( this ).attr('type') == "date") {
            var humanReadableDate = value && "";
            var machineReadableDate = value ? document.getElementById(id).valueAsDate.toISOString() : "";
            template = replaceAll(template,"{"+id+"-human}",humanReadableDate);
            template = replaceAll(template,"{"+id+"-machine}",machineReadableDate);
        } else if ($( this ).attr('id') == "odi-certificate-number") {
            if (value == "") {
                template = replaceAll(template,"{odi-certificate-show}","none");
            } else {
                template = replaceAll(template,"{odi-certificate-show}","inline-block");
            }
            template = replaceAll(template,"{odi-certificate-number}",value);
        } else {
            template = replaceAll(template,"{"+id+"}",value);
        }
    });

    $( "#output" ).val(template);
}

function standalone(templateFile, stateFile, outputFile) {
    var fs = require('fs');
    fs.writeFile("/tmp/test", "Hey there!", function(err) {
        if(err) {
            return console.log(err);
        }

        console.log("The file was saved!");
    }
}); 
}