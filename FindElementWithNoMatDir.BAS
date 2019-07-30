Sub Main
    Dim App As femap.model
    Set App = feFemap()
	'=========================================
	'Program to find laminate elements with 'default' material
	'direction, create a group, and add them all to the group.
	'
	'Copyright (c) 2019 Aaron Jasso
	'
	'Licensed under the Apache License, Version 2.0 (the "License");
	'you may not use this file except in compliance with the License.
	'You may obtain a copy of the License at
	'
	'    http://www.apache.org/licenses/LICENSE-2.0
	'
	'Unless required by applicable law or agreed to in writing, software
	'distributed under the License Is distributed On an "AS IS" BASIS,
	'WITHOUT WARRANTIES Or CONDITIONS OF Any KIND, either express Or implied.
	'See the License For the specific language governing permissions And
	'limitations under the License.
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
