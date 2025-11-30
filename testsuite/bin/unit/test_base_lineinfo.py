# ------------------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2025 Jayesh Badwaik <j.badwaik@fz-juelich.de>
# ------------------------------------------------------------------------------

import json
from dataclasses import FrozenInstanceError

import pytest
import korml.base


class TestLineInfo:
    @pytest.fixture
    def lineinfo(self):
        # Common LineInfo used by tests in this group
        return korml.base.LineInfo(10, 20)

    def test_init_and_properties(self, lineinfo):
        assert lineinfo.line == 10
        assert lineinfo.column == 20

        # internal underscore attributes still exist
        assert lineinfo._line == 10
        assert lineinfo._column == 20

    def test_json_output(self, lineinfo):
        result = lineinfo.json()

        assert isinstance(result, dict)
        assert result == {"line": 10, "column": 20}

        # json-serializable
        dumped = json.dumps(result)
        assert json.loads(dumped) == result

    def test_str(self, lineinfo):
        assert str(lineinfo) == "LineInfo(line=10, column=20)"

    def test_equality_same_values(self):
        li1 = korml.base.LineInfo(3, 7)
        li2 = korml.base.LineInfo(3, 7)

        assert li1 == li2
        assert li2 == li1

    def test_equality_different_values(self):
        base = korml.base.LineInfo(5, 8)
        diff_line = korml.base.LineInfo(6, 8)
        diff_col = korml.base.LineInfo(5, 9)

        assert base != diff_line
        assert base != diff_col

    def test_equality_different_type(self):
        li = korml.base.LineInfo(1, 1)
        assert li != (1, 1)

    def test_frozen_immutability(self, lineinfo):
        with pytest.raises(FrozenInstanceError):
            lineinfo._line = 99
        with pytest.raises(FrozenInstanceError):
            lineinfo._column = 42


class TestFileInfo:
    @pytest.fixture
    def fileinfo(self):
        li = korml.base.LineInfo(4, 15)
        return korml.base.FileInfo("main.py", li)

    def test_init_and_properties(self, fileinfo):
        assert fileinfo.filename == "main.py"
        assert isinstance(fileinfo.lineinfo, korml.base.LineInfo)

        # internal underscore attributes
        assert fileinfo._filename == "main.py"
        assert fileinfo._lineinfo == fileinfo.lineinfo

    def test_json_output(self, fileinfo):
        result = fileinfo.json()

        assert isinstance(result, dict)
        assert result == {
            "filename": "main.py",
            "lineinfo": {"line": 4, "column": 15},
        }

        dumped = json.dumps(result)
        assert json.loads(dumped) == result

    def test_str(self, fileinfo):
        assert str(fileinfo) == ("FileInfo(filename=main.py, lineinfo=LineInfo(line=4, column=15))")

    def test_equality_same_values(self):
        li1 = korml.base.LineInfo(1, 1)
        li2 = korml.base.LineInfo(1, 1)

        fi1 = korml.base.FileInfo("a.py", li1)
        fi2 = korml.base.FileInfo("a.py", li2)

        assert fi1 == fi2
        assert fi2 == fi1

    def test_equality_different_values(self):
        li = korml.base.LineInfo(1, 1)

        fi1 = korml.base.FileInfo("a.py", li)
        fi2 = korml.base.FileInfo("b.py", li)
        fi3 = korml.base.FileInfo("a.py", korml.base.LineInfo(2, 2))

        assert fi1 != fi2
        assert fi1 != fi3

    def test_equality_different_type(self, fileinfo):
        assert fileinfo != ("main.py", fileinfo.lineinfo)

    def test_frozen_immutability(self, fileinfo):
        with pytest.raises(FrozenInstanceError):
            fileinfo._filename = "other.py"
        with pytest.raises(FrozenInstanceError):
            fileinfo._lineinfo = korml.base.LineInfo(99, 99)
