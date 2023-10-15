Shader "Custom/BlinnPhong"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Shininess ("Shininess", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry"}
        

        Pass{
            Name "OmaPass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        HLSLPROGRAM

        #pragma vertex VertexFunction
        #pragma fragment FragmentFunction

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
        };

        struct Varyings
        {
            // Just to be clear. If you want me to use some specific naming convention with variables,
            // then you should write somewhere, what each of them means. Like the idea of how the naming works.
            // Because in my eyes I could as well name these as cats, dogs, wolves, and bears... and the
            // code would still work as intended.
            float4 positionHCS : SV_POSITION;
            float3 positionWS : TEXCOORD0;
            float3 normalWS : TEXCOORD1;
        };

        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float _Shininess;
        CBUFFER_END

        Varyings VertexFunction(const Attributes input)
        {
            Varyings output;
            // M = model, V = view, P = projection
            //output.positionHCS = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, float4(input.positionOS,1))));
            output.positionHCS = TransformObjectToHClip(input.positionOS);
            //output.positionWS = mul(UNITY_MATRIX_M,input.positionOS);
            output.positionWS = TransformObjectToWorld(input.positionOS);
            
            output.normalWS = TransformObjectToWorldNormal(input.normalOS);

            return output;
        }

        float4 BlinnPhong(Varyings input)
        {
            const Light mainLight = GetMainLight();
            const float3 ambientLight = 0.1 * mainLight.color;
            const float3 diffuse = saturate(dot(input.normalWS, mainLight.direction)) * mainLight.color;
            const float3 viewDir = GetWorldSpaceNormalizeViewDir(input.positionWS);
            const float3 halfwayVector = normalize(mainLight.direction + viewDir);
            const float3 specLight = pow(saturate(dot(input.normalWS, halfwayVector)), _Shininess) * mainLight.color;
            float4 color = float4((ambientLight + diffuse + specLight) * _Color, 1);
            return color;
        }

        float4 FragmentFunction(const Varyings input) : SV_Target
        {
            return BlinnPhong(input);
        }
        
        ENDHLSL    
        } 
    }
}
