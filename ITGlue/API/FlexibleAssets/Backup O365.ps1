$data = @{
	type = "flexible_asset_types"
	attributes = @{
		icon = "envelope-o"
		description = ''
		name = "Backup O365"
		enabled = $true
	}
	relationships = @{
		flexible_asset_fields = @{
			data = @(
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 1
						name = "O365 licenses that are backed up"
						kind = "Tag"
						hint = "Tag the O365 licenses that are backed up."
						tag_type = "FlexibleAssetType: $((Get-ITGlueFlexibleAssetTypes -filter_name 'Office 365 Licenses').data.id)"
						required = $true
						use_for_title = $false
						show_in_list = $true
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 2
						name = "Backed up sources:"
						kind = "Header"
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 3
						name = "Exchange"
						kind = "Checkbox"
						hint = "Is this source backed up?"
						required = $false
						use_for_title = $false
						show_in_list = $true
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 4
						name = "OneDrive"
						kind = "Checkbox"
						hint = "Is this source backed up?"
						required = $false
						use_for_title = $false
						show_in_list = $true
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 5
						name = "SharePoint"
						kind = "Checkbox"
						hint = "Is this source backed up?"
						required = $false
						use_for_title = $false
						show_in_list = $false
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 6
						name = "Retention Policy"
						kind = "Select"
						hint = "How long do we keep the data?"
						required = $true
						use_for_title = $false
						show_in_list = $true
						default_value = "Keep 60 days`r`n" `
									  + "nKeep 90 days`r`n" `
									  + "nOne year`r`n" `
									  + "nKeep forever"
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 7
						name = "Special Backup Policy/Preferences"
						kind = "Textbox"
						hint = ''
						required = $false
						use_for_title = $false
						show_in_list = $true
						default_value = ""
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 8
						name = "Schedules:"
						kind = "Header"
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 9
						name = "Monday"
						kind = "Checkbox"
						hint = "The days on which this backup schedule is to run."
						required = $false
						use_for_title = $false
						show_in_list = $true
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 10
						name = "Tuesday"
						kind = "Checkbox"
						hint = "The days on which this backup schedule is to run."
						required = $false
						use_for_title = $false
						show_in_list = $true
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 11
						name = "Wednesday"
						kind = "Checkbox"
						hint = "The days on which this backup schedule is to run."
						required = $false
						use_for_title = $false
						show_in_list = $true
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 12
						name = "Thursday"
						kind = "Checkbox"
						hint = "The days on which this backup schedule is to run."
						required = $false
						use_for_title = $false
						show_in_list = $true
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 13
						name = "Friday"
						kind = "Checkbox"
						hint = "The days on which this backup schedule is to run."
						required = $false
						use_for_title = $false
						show_in_list = $true
				}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 14
						name = "Saturday"
						kind = "Checkbox"
						hint = "The days on which this backup schedule is to run."
						required = $false
						use_for_title = $false
						show_in_list = $true
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 15
						name = "Sunday"
						kind = "Checkbox"
						hint = "The days on which this backup schedule is to run."
						required = $false
						use_for_title = $false
						show_in_list = $true
					}
				},
				@{
				type = "flexible_asset_fields"
					attributes = @{
						order = 16
						name = "Daily Backup Timeline  (24-hour time format)."
						kind = "Text"
						hint = "Set the time at which backup runs begin."
						required = $true
						use_for_title = $false
						show_in_list = $true
						default_value = "00:00"
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 17
						name = "Repeat every"
						kind = "Text"
						hint = "How often is the backup repeated?"
						required = $true
						use_for_title = $false
						show_in_list = $true
						default_value = "30 minutes"
					}
				},
				@{
					type = "flexible_asset_fields"
					attributes = @{
						order = 18
						name = "Until  (24-hour time format)."
						kind = "Text"
						hint = "When is the last backup taken?"
						required = $true
						use_for_title = $false
						show_in_list = $true
						default_value = "23:00"
					}
				}
			)
		}
	}
}
New-ITGlueFlexibleAssetTypes -data $data