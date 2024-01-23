import os
import datetime
import yaml

#
# Rules:
#
#   DBT seems to have a hierarchy for documentation blocks.  When single packages are being worked on the documentation
#   __overview__ block is used as the top level of documentation for describing the documentation site.   However,
#   when a documentation 'super' project is put together that pulls in indvidual projects as packages into a
#   single project, then a slightly different behaviour occurs.   The super project can only have one __overview__ defined
#   however when projects are pulled in then multiple __overview__ blocks become defined and DBT seems to choose either one
#   at random, or possible the first overview block process is used.
#
#   Individual __<package_name>__ may be defined for each package, however these need to 'live' in the 'super' project.
#
#   A further challenge is that for any packages that do not (yet !) have an overview, DBT assigns a random description for the
#   project description, or worse just leaves blanks spaces.
#
#   This script resolves these issues, it does the following following:
#
#       Parses through each of the packages looking for an '__overview__' block in the overview.md file located in the ./docs folder.
#       It then renames the __overview__ block to the package name block and writes it to the super project ./docs folder wtihin the
#       package_overview_blocks.md file.
#
#       If a package does not have an overview block, it auto-generates a simple block.
#



#
#   Create a simple object to carry around useful information about packages and the document blocks.
#
class DocumentationBlock:

    def __init__(self,name):
        self.relative_path = os.path.join("","/home","astro","documentations","dbt_packages")
        self.overview_block_array = []
        self.name = name
        self.has_documentation_folder = False
        self.has_documentation_overview_block = False
        self.populate_from_dbt_structure()


    def __str__(self):
        return "Block Name: {}".format(self.name)


    def setblock_array(self, block):
        self.block_array = block


    def populate_from_dbt_structure(self):
        try:

            self.read_documentation_block()

        except Exception as e:
            print(e)

    def read_documentation_block(self):
        try:

            package_docs_folder = os.path.join(self.relative_path,self.name, 'docs')
            package_docs_overiew_file = os.path.join(package_docs_folder, "overview.md".format(self.name))

            if os.path.exists(package_docs_folder):
                self.has_documentation_folder = True

            if os.path.exists(package_docs_overiew_file):
                self.has_documentation_overview_block = True

                self.overview_block_array = self.read_package_block(package_docs_overiew_file)

        except Exception as e:
            print(e)

    #
    #    This is rather clunky - but is works !
    #
    def read_package_block(self, pathname):
        try:

            print(pathname)

            overview_block = []

            with open(pathname,'r') as f:
                lines = f.readlines()

                open_block = False

                for l in lines:
                    elements  = l.split()

                    opening_block_line = False

                    if len(elements) >= 3:
                        # Do I have the start of a block
                        if elements[0] == "{%" and elements[1] == "docs" and elements[2] == "__{}__".format(self.name):
                            open_block = True
                            opening_block_line = True
                        elif elements[0] == "{%" and elements[1] == "enddocs" and elements[2] == "%}":
                            open_block = False

                    if open_block == True and opening_block_line == False:
                        overview_block.append(l)

            return overview_block

        except Exception as e:
            print(e)

    #
    #   Get the documentation block array
    #   If it exists - i.e. we have read it from a MD file, then return with the header and footer tags.
    #   If it does not exist - generate a generic one.
    #
    def get_overview_block(self):
        try:
            output_array = []

            # Add the header
            header_record = "{{% docs __{}__ %}}\n".format(self.name)
            footer_record = "{% enddocs %}\n\n\n"

            utc_time = datetime.datetime.utcnow()



            output_array.append(header_record)

            if self.has_documentation_overview_block:

                print("Transforming __overview__ block for {} to __{}__ block.".format(self.name, self.name))

                #   Add the existing content
                for l in self.overview_block_array:
                    output_array.append(l)
            else:
                #
                #   Add some generic content
                #
                print("No __overview__ block for {}.  Autogenerating new __{}__ block.".format(self.name, self.name))


                output_array.append("\n")
                output_array.append("### Welcome to the {} package\n".format(self.name))
                output_array.append("\n")
                output_array.append("This header is currently autogenerated.\n\n")
                output_array.append("Please complete the overview.md file which can\n")
                output_array.append("be found in the ./docs folder of the source DBT project.\n")
                output_array.append("\n")

            output_array.append("timestamp: {}\n".format(utc_time.strftime('%Y-%m-%d %H:%M:%S')))
            output_array.append(footer_record)

            return output_array


        except Exception as e:
            print(e)


    #
    #   Write the document block
    #
    def write_package_block(self):
        try:

            docs_filename = os.path.join('/tmp',"astro",'documentations','dbt_packages','package_overview_blocks.md' )
            with open(docs_filename,'a') as f:
                block = self.get_overview_block()

                for l in block:
                    f.write("{}".format(l))

        except Exception as e:
            print(e)




def get_package_blocks():

    try:
        package_blocks = []

        relative_path = os.path.join("","/home","astro","documentations","dbt_packages")

        for directories in os.listdir(relative_path):
            relative_directory = os.path.join(relative_path, directories)
            el = relative_directory.split('/')
            package_name = el[len(el) - 1]

            block = DocumentationBlock(package_name)
            package_blocks.append(block)


        return package_blocks

    except Exception as e:
            print(e)





#
#   Return an array of documentation block objects
#
def get_package_details_from_yml():
    try:

        documentation_blocks = []

        # Open the file
        with open("./documentations/packages.yml","r") as f:
            y = yaml.safe_load(f)

        for key, value in y.items():

            if key == 'packages':

                for l in value:

                    #
                    #   This is clunky - get the packname by spliting to a list
                    #
                    el = l['local'].split("/")

                    # ----- and then selecting the last element in the array
                    block = DocumentationBlock(el[len(el) - 1])
                    documentation_blocks.append(block)

        return documentation_blocks

    except Exception as e:
        print(e)


def main():
    try:

        print("Documentation overview generator.")
        print("{}".format(os.getcwd()))

        # this script has each block 'append' to to the package_overview_blocks.md file.  For this reason, on each run
        # we need to remove the file for the blocks start appending to it !
        docs_filename = os.path.join('/tmp',"astro",'documentations','dbt_packages','package_overview_blocks.md' )
        if os.path.exists(docs_filename):
            os.remove(docs_filename)

        #
        #   Get the package blocks
        #
        package_blocks = get_package_blocks()

        #
        #   Iterate through and create the new package_overview_blocks.md file
        #
        for blocks in package_blocks:
            blocks.write_package_block()



    except Exception as e:
        print("Failed to initialse python script")
        print(e)





if __name__ == "__main__":
    main()
