package register
{{ with $service := .}}
import (
	"context"
	api "{{$service.URL}}/api"
	service "{{$service.URL}}/internal/service"
	_ "gitlab.intelligentb.com/devops/bplus"                   // initialize BPlus first to make sure
	// that all BPLUS modules are loaded
	bplus "gitlab.intelligentb.com/devops/bplus/fw"
)
func init(){
	var sd =  bplus.ServiceDescriptor{
		ServiceToInvoke: service.Make{{$service.CamelCase}}Service(),
		Name:            "{{$service.Name}}",
		Operations:      OperationDescriptors(),
	}
	bplus.RegisterService("{{$service.Name}}", sd)
}

func OperationDescriptors()([]bplus.OperationDescriptor){
	return []bplus.OperationDescriptor{
		{{range $index,$elem := $service.Operations}}
		bplus.OperationDescriptor{
			Name:        "{{$elem.Operation}}",
			URL:             "/{{$elem.URL}}",
			HTTPMethod:      "{{$elem.Method}}",
			{{if $elem.RequestPayload -}}
			OpRequestMaker:  make{{$elem.Operation}}Request,
			{{- end}}
			{{if $elem.ResponsePayload -}}
			OpResponseMaker: make{{$elem.Operation}}Response,
			{{- end}}
			Params:          {{$elem.Operation}}PD(),
		},
		{{end}}
	}
}

{{range $index,$elem := $service.Operations}}
func {{$elem.Operation}}PD()([]bplus.ParamDescriptor){
	
	return []bplus.ParamDescriptor{
		{{range $index,$p := $elem.Params}}
		bplus.ParamDescriptor{
			Name:        "{{$p.Name}}",
			ParamOrigin: {{$p.Origin}},
			{{if $p.Kind -}} ParamKind: {{$p.Kind}}, {{- end}}
		},
		{{end}}
	}
}
{{end}}

{{range $index,$value := $service.Operations}}
{{if $value.RequestPayload -}}
func make{{$value.Operation}}Request(ctx context.Context)(interface{},error){
	return {{$value.RequestPayloadDefaultValue}},nil
}
{{- end}}

{{if $value.ResponsePayload -}}
func make{{$value.Operation}}Response(ctx context.Context)(interface{},error){
	return {{$value.ResponsePayloadDefaultValue}},nil
}
{{- end}}
{{- end}}

{{- end}} 
	