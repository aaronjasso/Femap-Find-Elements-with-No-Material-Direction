Sub Main
    Dim App As femap.model
    Set App = feFemap()
	'=========================================
	'Program to find laminate elements with 'default' material
	'direction, create a group, and add them all to the group.
	'
	'Copyright (c) 2019 Aaron Jasso
	'
	'This program is free software: you can redistribute it and/or modify
	'it under the terms of the GNU General Public License as published by
	'the Free Software Foundation, either version 3 of the License, or
	'(at your option) any later version.
	'
	'This program is distributed in the hope that it will be useful,
	'but WITHOUT ANY WARRANTY; without even the implied warranty of
	'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	'GNU General Public License for more details.
	'
	'You should have received a copy of the GNU General Public License
	'along with this program.  If not, see <https://www.gnu.org/licenses/>.
	'
	'----------------------------------------------------------------------------------------------------
	'Please comment or contribute at https://github.com/aaronjasso/Femap-Find-Elements-with-No-Material-Direction
	'
	'Note that only linear laminate elements are evaluated. If
	'parabolic or solid elements are used, modify the line with
	'elemSet.AddRule to use FET_P_LAMINATE_PLATE or
	'FET_L_LAMINATE_SOLID or FET_P_LAMINATE_SOLID instead.
	'
	'Version 1
	'Written by AMJ, 10/11/2017
	'=========================================
	Dim rc As Variant

	'fill set with all laminate elements
	Dim elemSet As femap.Set
	Set elemSet = App.feSet
	rc = elemSet.AddRule(FET_L_LAMINATE_PLATE, FGD_ELEM_BYTYPE)
	If elemSet.Count = 0 Then
		MsgBox("No laminate elements found in current model.", vbInformation,"Cannot Continue")
		Exit Sub
	End If

	'iterate through elements and add elements with no mat dir to new set
	Dim iterElem As femap.Elem
	Set iterElem = App.feElem
	Dim groupSet As femap.Set
	Set groupSet = App.feSet

	While elemSet.Next
		iterElem.Get(elemSet.CurrentID)
		If iterElem.MaterialOrientType = 0 Then
			groupSet.AddRule(iterElem.ID,  FGD_ELEM_ID)
		End If
	Wend

	If groupSet.Count = 0 Then
		MsgBox("All laminate elements have a defined Material Orientation.",vbInformation, "Program Complete")
		Exit Sub
	End If

	'create group and store all elems with no mat dir
	Dim GID As Long
	Dim newGroup As femap.Group
	Set newGroup = App.feGroup

	GID = App.feGroup.NextEmptyID
	newGroup.SetAdd2(FGR_ELEM,groupSet.ID)
	newGroup.title = "Laminate Elements with no Material Direction"
	rc = newGroup.Put(GID)

	If rc = FE_OK Then
		MsgBox("Created Group " & GID & " containing " & groupSet.Count & " element(s).",vbInformation,"Group Created")
	Else
		MsgBox("Could not create group, program terminated.",vbCritical,"Error")
	End If

End Sub
