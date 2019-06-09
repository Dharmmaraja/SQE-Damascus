from configparser import ConfigParser


def config_item(filename, section):
    """ 
    Create a configuration and export PATH
    :filename: specified .ini file
    :section: desired section in the .ini file
    :return: section
    """
    parser = ConfigParser()

    parser.read(filename)

    items = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            items[param[0]] = param[1]
    else:
        raise Exception('Section {} is not found in {}'.format(section, filename))
    return items

def config_qumrandse(filename='database.ini', section='damascus'):
    """
    Establish the configuration to the Critical Editions of Second Temple Texts database
    :return: database connection
    """
    db_path = config_item('database.ini', 'damascus')
    return db_path

        
def config_qwb():
    """
    Establish the configuration to the Critical Editions of Second Temple Texts database
    :return: database connection
    """
    db_path = config_item('database.ini', 'QWB')
    return db_path

def config_wivu():
    """
    Establish the configuration to the Critical Editions of Second Temple Texts database
    :return: database connection
    """
    db_path = config_item('database.ini', 'WIVU')
    return db_path

def img_docs():
    """
    Serve the PATH to the img docs directory
    """
    docs = config_item('path.ini', 'PATHS')
    return docs['path_to_img_db']

def img():
    """
    Serve the PATH to the img directory
    """
    img = config_item('paths.ini', 'PATHS')
    return img['path_to_img']

def nli_url():
    """
    The config file for URLS contains sites of interest to my research
    """
    urls = config_item('urls.ini', 'URLS')
    return urls['nli']

def img_db():
    """
    Export connection to the IAA Image database filenames
    """
    dbs = config_item('database.ini', 'DB')
    return dbs['img']