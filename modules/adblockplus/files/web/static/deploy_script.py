#!/usr/bin/env python

import argparse
from filecmp import dircmp
import hashlib
import os
import sys
import shutil
import tarfile
import tempfile
import urllib


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
        remove_tree(os.path.join(dcmp.left + "/" + name))
    for name in dcmp.right_only:
        copytree(dcmp.right, dcmp.left)
    for sub_dcmp in dcmp.subdirs.values():
        deploy_files(sub_dcmp)


def copytree(src, dst):
    if not os.path.exists(dst):
        os.makedirs(dst)
        shutil.copystat(src, dst)
    lst = os.listdir(src)
    for item in lst:
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            copytree(s, d)
        else:
            shutil.copy2(s, d)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="""Fetch a compressed archive in the form of $HASH.tar.gz
                    and deploy it to /var/www/$WEBSITE folder""",
        epilog="""--hash must be provided in order to fetch the files,
               expected files to be fetched are $HASH.tar.gz and $HASH.md5 in
               order to compare the hashes.
               --source must be an URL, e.g.
               https://helpcenter.eyeofiles.com""",
    )
    parser.add_argument('--hash', action='store', type=str,
                        required=True,
                        help='Hash of the commit to deploy')
    parser.add_argument('--source', action='store', type=str,
                        required=True,
                        help='The source where files will be downloaded')
    parser.add_argument('--website', action='store', type=str,
                        help='The name of the website [e.g. help.eyeo.com]')
    args = parser.parse_args()
    hash = args.hash
    source = args.source
    url_file = '{0}/{1}.tar.gz'.format(source, hash)
    url_md5 = '{0}/{1}.md5'.format(source, hash)
    tmp_dir = tempfile.mkdtemp()
    try:
        down_file = download(url_file, tmp_dir)
        down_md5 = download(url_md5, tmp_dir)
        if calculate_md5(down_file) == read_md5(down_md5):
            untar(down_file, tmp_dir)
            hash_directory = os.path.join(tmp_dir, hash)
            destination = os.path.join('/var/www/', args.website)
            dcmp = dircmp(destination, hash_directory)
            print 'Deploying files'
            deploy_files(dcmp)
        else:
            sys.exit("Hashes don't match")
    except Exception as e:
        sys.exit(e)
    finally:
        shutil.rmtree(tmp_dir)