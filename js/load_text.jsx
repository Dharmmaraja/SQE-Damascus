// This Script loads a text into Photoshop

var doc = activeDocument

// Create File if not Already
var textFile = new File(Folder.desktop+ '/line.txt')
var list = readText (textFile).split('\n')

// Create an individual layer for each word
for (var i = 0; i < list.length; i++){
    var artLayerRef = doc.artLayers.add()
    artLayerRef.kind = LayerKind.TEXT;
    artLayerRef.textItem.font = "4Q256";
    artLayerRef.textItem.size = 44;
    var textItemRef = artLayerRef.textItem;
    textItemRef.contents = list[i]
}

function readText(file) {
    if (textFile.exists) {
        textFile.encoding = "UTF8";
        textFile.lineFeed = "unix";
        textFile.open("r", "TEXT", "????");
        var str = textFile.read();
        return str;
    }
}

// UPDATE
// 1. Connect to qumran_dse database to get text
// 2. Get font Metrics from schriftenmetric table
// 3. Ask for column width
// 4. Write text within column