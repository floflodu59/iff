#!/bin/bash

function update
{
	git clone https://github.com/floflodu59/iff.git /backup/temp/iff
	cp /backup/temp/iff/bin/backup/scripts/export.sh /backup/scripts/export.sh
	cp /backup/temp/iff/bin/backup/scripts/errorhandler.sh /backup/scripts/errorhandler.sh
	cp /backup/temp/iff/bin/backup/scripts/update.sh /backup/scripts/update.sh
	rm -rf /backup/temp/iff
}