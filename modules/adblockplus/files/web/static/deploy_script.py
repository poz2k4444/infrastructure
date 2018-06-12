#!/usr/bin/env python
#
# This file is part of the Adblock Plus infrastructure
# Copyright (C) 2018-present eyeo GmbH
#
# Adblock Plus is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# Adblock Plus is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Adblock Plus.  If not, see <http://www.gnu.org/licenses/>.

import argparse
from filecmp import dircmp
import hashlib
import os
import sys
import shutil
import tarfile
import tempfile
import urllib


_doc = """--name must be provided in order to fetch the files,
       expected files to be fetched are $NAME.tar.gz and $NAME.md5 in
       order to compare the hashes.
       --source must be an URL, e.g.
       https://helpcenter.eyeofiles.com"""


def download(url, tmp_dir):
    file_name = url.split('/')[-1]
    abs_file_name = os.path.join(tmp_dir, file_name)
    print 'Downloading: ' + file_name
    urllib.urlretrieve(url, abs_file_name)
    return abs_file_name


def calculate_md5(file):
    with open(file) as f:
        data = f.read()
        md5_result = hashlib.md5(data).hexdigest()
    return md5_result.strip()


def read_md5(file):
    with open(file) as f:
        md5_result = f.readline()
    return md5_result.strip()


def untar(tar_file, tmp_dir):
    if tarfile.is_tarfile(tar_file):
        with tarfile.open(tar_file, 'r:gz') as tar:
            tar.extractall(tmp_dir)


def remove_tree(to_remove):
    if os.path.exists(to_remove):
        if os.path.isdir(to_remove):
            shutil.rmtree(to_remove)
        else:
            os.remove(to_remove)


def deploy_files(dcmp):
    for name in dcmp.diff_files:
        copytree(dcmp.right, dcmp.left)
    for name in dcmp.left_only:
        remove_tree(os.path.join(dcmp.left, name))
    for name in dcmp.right_only:
        copytree(dcmp.right, dcmp.left)
    for sub_dcmp in dcmp.subdirs.values():
        deploy_files(sub_dcmp)


# shutil.copytree copies a tree but the destination directory MUST NOT exist
# this might break the site for the duration of the files being deployed
# for more info read: https://docs.python.org/2/library/shutil.html
def copytree(source, destination):
    if not os.path.exists(destination):
        os.makedirs(destination)
        shutil.copystat(source, destination)
    source_items = os.listdir(source)
    for item in source_items:
        source_path = os.path.join(source, item)
        destination_path = os.path.join(destination, item)
        if os.path.isdir(source_path):
            copytree(source_path, destination_path)
        else:
            shutil.copy2(source_path, destination_path)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="""Fetch a compressed archive in the form of $NAME.tar.gz
                    and deploy it to /var/www/$WEBSITE folder""",
        epilog=_doc,
    )
    parser.add_argument('--name', action='store', type=str, required=True,
                        help='Name of the tarball to deploy')
    parser.add_argument('--source', action='store', type=str, required=True,
                        help='The source where files will be downloaded')
    parser.add_argument('--website', action='store', type=str,
                        help='The name of the website [e.g. help.eyeo.com]')
    args = parser.parse_args()
    name = args.name
    source = args.source
    url_file = '{0}/{1}.tar.gz'.format(source, name)
    url_md5 = '{0}/{1}.md5'.format(source, name)
    tmp_dir = tempfile.mkdtemp()
    try:
        down_file = download(url_file, tmp_dir)
        down_md5 = download(url_md5, tmp_dir)
        if calculate_md5(down_file) == read_md5(down_md5):
            untar(down_file, tmp_dir)
            name_directory = os.path.join(tmp_dir, name)
            destination = os.path.join('/var/www/', args.website)
            dcmp = dircmp(destination, name_directory)
            print 'Deploying files'
            deploy_files(dcmp)
        else:
            sys.exit("Hashes don't match")
    except Exception as e:
        sys.exit(e)
    finally:
        shutil.rmtree(tmp_dir)
