/*
  (c) 2016 by Sebastian J. Wolf
  www.wunderfitz.org
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    initialPage: Component { TitlePage { } }
    cover: Component { CoverPage { } }
    allowedOrientations: Orientation.All
}


