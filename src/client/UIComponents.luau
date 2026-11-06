--!strict
local C={}
C.Color={Background=Color3.fromRGB(15,19,25),Panel=Color3.fromRGB(24,30,38),Raised=Color3.fromRGB(31,39,49),Border=Color3.fromRGB(53,65,79),Text=Color3.fromRGB(235,240,245),Muted=Color3.fromRGB(153,169,184),Mint=Color3.fromRGB(124,224,196),Gold=Color3.fromRGB(227,189,119),Purple=Color3.fromRGB(165,157,229),Red=Color3.fromRGB(231,133,133)}
function C.round(parent: Instance,radius: number?) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,radius or 12); c.Parent=parent end
function C.border(parent: Instance,color: Color3?) local s=Instance.new("UIStroke"); s.Color=color or C.Color.Border; s.Transparency=0.3; s.Parent=parent end
function C.frame(parent: Instance,size: UDim2,pos: UDim2?,color: Color3?): Frame
 local f=Instance.new("Frame"); f.Size=size; f.Position=pos or UDim2.new(); f.BackgroundColor3=color or C.Color.Panel; f.BorderSizePixel=0; f.Parent=parent; if parent:IsA("GuiObject") then f.ZIndex=parent.ZIndex+1 end; return f
end
function C.label(parent: Instance,value: string,size: number,color: Color3?,area: UDim2?,pos: UDim2?): TextLabel
 local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Size=area or UDim2.new(1,0,0,24); t.Position=pos or UDim2.new(); t.Text=value; t.TextColor3=color or C.Color.Text; t.Font=Enum.Font.GothamMedium; t.TextSize=size; t.TextWrapped=true; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextYAlignment=Enum.TextYAlignment.Center; if parent:IsA("GuiObject") then t.ZIndex=parent.ZIndex+1 end; t.Parent=parent; return t
end
function C.button(parent: Instance,title: string,area: UDim2,pos: UDim2?,callback: ()->(),color: Color3?): TextButton
 local b=Instance.new("TextButton"); b.Size=area; b.Position=pos or UDim2.new(); b.BackgroundColor3=color or C.Color.Mint; b.TextColor3=if color==C.Color.Raised then C.Color.Text else C.Color.Background; b.Text=title; b.Font=Enum.Font.GothamBold; b.TextSize=13; b.AutoButtonColor=true; b.Selectable=true; if parent:IsA("GuiObject") then b.ZIndex=parent.ZIndex+1 end; b.Parent=parent; C.round(b,9); b.Activated:Connect(callback); return b
end
function C.list(parent: Instance,padding: number?,horizontal: boolean?): UIListLayout
 local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,padding or 12); l.SortOrder=Enum.SortOrder.LayoutOrder; if horizontal then l.FillDirection=Enum.FillDirection.Horizontal end; l.Parent=parent; return l
end
function C.scroll(parent: Instance,area: UDim2,pos: UDim2?,horizontal: boolean?): ScrollingFrame
 local f=Instance.new("ScrollingFrame"); f.Size=area; f.Position=pos or UDim2.new(); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.ScrollBarThickness=3; f.ScrollBarImageColor3=C.Color.Border; f.AutomaticCanvasSize=if horizontal then Enum.AutomaticSize.X else Enum.AutomaticSize.Y; f.ScrollingDirection=if horizontal then Enum.ScrollingDirection.X else Enum.ScrollingDirection.Y; f.CanvasSize=UDim2.new(); if parent:IsA("GuiObject") then f.ZIndex=parent.ZIndex+1 end; f.Parent=parent; return f
end
function C.progress(parent: Instance,pos: UDim2,area: UDim2,fraction: number,color: Color3?): Frame
 local rail=C.frame(parent,area,pos,C.Color.Background); C.round(rail,4)
 local fill=C.frame(rail,UDim2.fromScale(math.clamp(fraction,0,1),1),nil,color or C.Color.Mint); C.round(fill,4); return fill
end
function C.number(value: number): string local s=tostring(math.floor(value)); local t=s:reverse():gsub("(%d%d%d)","%1,"):reverse(); return t:gsub("^,","") end
return C
