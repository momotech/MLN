<?xml version="1.0"?>
<recipe>
    <instantiate from="root/src/app_package/UD.java.ftl"
                   to="${escapeXmlAttribute(srcOut)}/${ClassName}.java" />

    <open file="${escapeXmlAttribute(srcOut)}/${ClassName}.java" />
</recipe>
