/*
  (c) 2016 by Sebastian J. Wolf
  www.wunderfitz.org
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.wunderfitz 1.0
import "pages"

ApplicationWindow
{
    Component {
        id: aboutPage
        AboutPage {}
    }

    Component {
        id: titlePage
        TitlePage {}
    }

    Component {
        id: dictionariesPage
        DictionariesPage {}
    }

    HeinzelnisseModel {
        id: heinzelnisseModel
    }

    DictCCImporterModel {
        id: dictCCImporterModel
    }

    DictionaryModel {
        id: dictionaryModel
    }

    id: window
    initialPage: titlePage
    cover: Component { CoverPage { } }
    allowedOrientations: Orientation.All

}


