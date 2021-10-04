--[[
	various sorting routines
]]

--this is based on code from Dirk Laurie and Steve Fisher,
--used under license as follows:

--[[
	Copyright © 2013 Dirk Laurie and Steve Fisher.

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including without limitation
	the rights to use, copy, modify, merge, publish, distribute, sublicense,
	and/or sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
	DEALINGS IN THE SOFTWARE.
]]

-- (modifications by Max Cahill 2018, 2020)
-- Stolen from Batteries: https://github.com/1bardesign/batteries/blob/master/sort.lua
-- Don't tell Max that I converted them to camelCase :marge:

local sort = {}

--tunable size for insertion sort "bottom out"
sort.max_chunk_size = 32

--insertion sort on a section of array
function sort.__insertionSortImpl(array, first, last, less)
	for i = first + 1, last do
		local k = first
		local v = array[i]
		for j = i, first + 1, -1 do
			if less(v, array[j - 1]) then
				array[j] = array[j - 1]
			else
				k = j
				break
			end
		end
		array[k] = v
	end
end

--merge sorted adjacent sections of array
function sort.__merge(array, workspace, low, middle, high, less)
	local i, j, k
	i = 1
	-- copy first half of array to auxiliary array
	for j = low, middle do
		workspace[i] = array[j]
		i = i + 1
	end
	-- sieve through
	i = 1
	j = middle + 1
	k = low
	while true do
		if (k >= j) or (j > high) then
			break
		end
		if less(array[j], workspace[i])  then
			array[k] = array[j]
			j = j + 1
		else
			array[k] = workspace[i]
			i = i + 1
		end
		k = k + 1
	end
	-- copy back any remaining elements of first half
	for k = k, j - 1 do
		array[k] = workspace[i]
		i = i + 1
	end
end

--implementation for the merge sort
function sort.__mergeSortImpl(array, workspace, low, high, less)
	if high - low <= sort.max_chunk_size then
		sort.__insertionSortImpl(array, low, high, less)
	else
		local middle = math.floor((low + high) / 2)
		sort.__mergeSortImpl(array, workspace, low, middle, less)
		sort.__mergeSortImpl(array, workspace, middle + 1, high, less)
		sort.__merge(array, workspace, low, middle, high, less)
	end
end

--default comparison; hoisted for clarity
local function defaultLess(a, b)
	return a < b
end

--inline common setup stuff
function sort.__sortSetup(array, less)
	--default less
	less = less or defaultLess
	--
	local n = #array
	--trivial cases; empty or 1 element
	local trivial = (n <= 1)
	if not trivial then
		--check less
		if less(array[1], array[1]) then
			error("invalid order function for sorting; less(v, v) should not be true for any v.")
		end
	end
	--setup complete
	return trivial, n, less
end

function sort.stableSort(array, less)
	--setup
	local trivial, n, less = sort.__sortSetup(array, less)
	if not trivial then
		--temp storage; allocate ahead of time
		local workspace = {}
		local middle = math.ceil(n / 2)
		workspace[middle] = array[1]
		--dive in
		sort.__mergeSortImpl( array, workspace, 1, n, less )
	end
	return array
end

function sort.insertionSort(array, less)
	--setup
	local trivial, n, less = sort.__sortSetup(array, less)
	if not trivial then
		sort.__insertionSortImpl(array, 1, n, less)
	end
	return array
end

sort.unstableSort = table.sort

--export sort core to the global table module
function sort:export()
	table.intertionSort = sort.insertionSort
	table.stableSort = sort.stableSort
	table.unstable_sort = sort.unstableSort
end

return sort