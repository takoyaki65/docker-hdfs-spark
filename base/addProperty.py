#!/usr/bin/env python3

# addProperty: add property to hadoop config file (which is xml format)
# args:
#   $1: path to config file (e.g. /etc/hadoop/core-site.xml)
#   $2: property name (e.g. fs.defaultFS)
#   $3: property value (e.g. hdfs://namenode:9000)

import argparse
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET


def add_property(config_path: str, property_name: str, property_value: str) -> None:
    """
    Add property to hadoop config file (which is xml format)

    Args:
        config_path: path to config file (e.g. /etc/hadoop/core-site.xml)
        property_name: property name (e.g. fs.defaultFS)
        property_value: property value (e.g. hdfs://namenode:9000)
    """
    try:
        config_file = Path(config_path)
        if not config_file.exists():
            print(f"Config file {config_path} does not exist")
            sys.exit(1)

        print(f"Adding property {property_name}={property_value} to {config_path}")

        # extract stylesheet specifiction from config file
        with open(config_path, "r", encoding="utf-8") as f:
            original_content = f.read()

        stylesheet_match = re.search(r"<\?xml-stylesheet[^?]*\?>", original_content)
        stylesheet_instruction = stylesheet_match.group(0) if stylesheet_match else None

        # Parse XML file
        tree = ET.parse(config_path)
        root = tree.getroot()

        # Check the existing property under <configuration>....</configuration>
        existing_property = root.find(f".//property[name='{property_name}']")

        if existing_property is not None:
            # update the existing property
            value_elem = existing_property.find("value")
            if value_elem is not None:
                # update the property value
                old_value = value_elem.text
                value_elem.text = property_value
                print(
                    f"Updated property {property_name} from {old_value} to {property_value}"
                )
            else:
                # add new value to existing property
                value_elem = ET.SubElement(existing_property, "value")
                value_elem.text = property_value
                print(f"Added new property {property_name}={property_value}")
        else:
            # add new property
            property_elem = ET.SubElement(root, "property")

            name_elem = ET.SubElement(property_elem, "name")
            name_elem.text = property_name

            value_elem = ET.SubElement(property_elem, "value")
            value_elem.text = property_value

            print(f"Added new property {property_name}={property_value}")

        # Save the updated XML back to the file with proper formatting
        ET.indent(tree, space="  ")

        xml_content = ET.tostring(root, encoding="unicode")

        with open(config_path, "w", encoding="utf-8") as f:
            f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
            if stylesheet_instruction:
                f.write(f"{stylesheet_instruction}\n")
            f.write(xml_content)
            f.write("\n")

        print(f"Updated {config_path} successfully")

    except ET.ParseError as e:
        print(f"XML parse error: {e}")
        sys.exit(1)
    except PermissionError:
        print(f"Permission denied: {config_path}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Tool to add property to hadoop config file (which is xml format)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
        Example:
        $ addProperty /etc/hadoop/core-site.xml fs.defaultFS hdfs://namenode:9000
        """,
    )

    parser.add_argument(
        "path", type=str, help="Path to config file (e.g. /etc/hadoop/core-site.xml)"
    )
    parser.add_argument("name", type=str, help="Property name (e.g. fs.defaultFS)")
    parser.add_argument(
        "value", type=str, help="Property value (e.g. hdfs://namenode:9000)"
    )

    args = parser.parse_args()

    add_property(args.path, args.name, args.value)


if __name__ == "__main__":
    main()
