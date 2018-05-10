#!/usr/bin/env python

import argparse
from contextlib import closing
from filecmp import dircmp
import hashlib
import os
import sys
import shutil
import tarfile
import urllib2


def download(url):
    file_name = url.split('/')[-1]
    abs_file_name = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                 file_name)
    print 'Downloading: ' + file_name
    try:
        with closing(urllib2.urlopen(url)) as page:
            block_sz = 8912
            with open(abs_file_name, 'wb') as f:
                while True:
                    buffer = page.read(block_sz)
                    if not buffer:
                        break
                    f.write(buffer)
        return abs_file_name
    except urllib2.HTTPError as e:
        if e.code == 404:
            sys.exit("File not found on remote source")
    except Exception as e:
        sys.exit(e)


def calculate_md5(file):
    with open(file) as f:
        data = f.read()
        md5_result = hashlib.md5(data).hexdigest()
    return md5_result.strip()


def read_md5(file):
    with open(file) as f:
        md5_result = f.readline()
    return md5_result.strip()


def untar(tar_file):
    if tarfile.is_tarfile(tar_file):
        with tarfile.open(tar_file, 'r:gz') as tar:
            tar.extractall(os.path.dirname(os.path.realpath(tar_file)))
            print 'Extracted in current directory'
            return os.path.dirname(os.path.abspath(__file__))


def remove_tree(to_remove):
    if os.path.exists(to_remove):
        if os.path.isdir(to_remove):
            shutil.rmtree(to_remove)
        else:
            os.remove(to_remove)


def clean(hash):
    print "cleaning directory"
    cwd = os.path.dirname(os.path.abspath(__file__))
    [remove_tree(os.path.join(cwd, x)) for x in os.listdir(cwd)
     if x.startswith(hash)]


def deploy_files(dcmp):
    for name in dcmp.diff_files:
        copytree(dcmp.right, dcmp.left)
    for name in dcmp.left_only:
        remove_tree(dcmp.left + "/" + name)
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
        description='''Fetch a compressed archive in the form of $HASH.tar.gz and
        deploys it to /var/www/$WEBSITE folder''',
        epilog="""--hash must be provided in order to fetch the files,
        expected files to be fetched are $HASH.tar.gz and $HASH.md5 in order to
        compare the hashes.
        --url and --domain are mutually exclusive, if url is provided
        the files will be downloaded from $url/$HASH, otherwise the default
        value will be fetched from $domain.eyeofiles.com/$HASH""",
    )
    parser.add_argument('--hash', action='store', type=str, nargs='?',
                        help='Hash of the commit to deploy')
    parser.add_argument('--url', action='store', type=str,
                        help='URL where files will be downloaded')
    parser.add_argument('--domain', action='store', type=str, nargs='?',
                        help='''The domain to prepend
                        [eg. https://$domain.eyeofiles.com]''')
    parser.add_argument('--website', action='store', type=str, nargs='?',
                        help='The name of the website [e.g. help.eyeo.com]')
    args = parser.parse_args()
    hash = args.hash
    domain = args.domain
    if args.url:
        url_file = '{0}/{1}.tar.gz'.format(args.url, hash)
        url_md5 = '{0}/{1}.md5'.format(args.url, hash)
    else:
        url_file = 'https://{0}.eyeofiles.com/{1}.tar.gz'.format(domain, hash)
        url_md5 = 'https://{0}.eyeofiles.com/{1}.md5'.format(domain, hash)
    down_file = download(url_file)
    down_md5 = download(url_md5)
    if calculate_md5(down_file) == read_md5(down_md5):
        tar_directory = untar(down_file)
        hash_directory = os.path.join(tar_directory, hash)
        destination = '/var/www/' + args.website
        dcmp = dircmp(destination, hash_directory)
        deploy_files(dcmp)
        clean(hash)
    else:
        sys.exit("Hashes don't match")
