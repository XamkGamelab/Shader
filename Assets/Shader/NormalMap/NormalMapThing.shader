Shader "Custom/BlinnPhongNormalMap"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _Shininess("Shininess", Range(1, 512)) = 1
        _SpeedX ("SpeedX", Float) = 0
        _SpeedY ("SpeedY", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        Pass
        {
            HLSLPROGRAM
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float2 uv : TEXCOORD4;
            };
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _NormalMap_ST;
            float _Shininess;
            float _SpeedX;
            float _SpeedY;
            CBUFFER_END

            TEXTURE2D(_MainTex);    SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap);   SAMPLER(sampler_NormalMap);
            
            Varyings vert (Attributes input)
            {
                Varyings output;

                const VertexPositionInputs position_inputs = GetVertexPositionInputs(input.positionOS);
                const VertexNormalInputs normal_inputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.positionHCS = position_inputs.positionCS;
                output.normalWS = normal_inputs.normalWS;
                output.tangentWS = normal_inputs.tangentWS;
                output.bitangentWS = normal_inputs.bitangentWS;
                output.positionWS = position_inputs.positionWS;

                output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw + _Time.y * float2(_SpeedX, _SpeedY);
                
                return output;
            }
            
            float4 BlinnPhong(const Varyings input, float4 color)
            {
                const Light mainLight = GetMainLight();
                
                const float3 ambientLight = 0.1 * mainLight.color;
                
                const float3 diffuseLight =  saturate(dot(input.normalWS, mainLight.direction)) * mainLight.color;
                
                const float3 viewDir = GetWorldSpaceNormalizeViewDir(input.positionWS);
                const float3 halfwayDir = normalize(mainLight.direction + viewDir);
                
                const float3 specularLight = pow(saturate(dot(input.normalWS, halfwayDir)), _Shininess) * mainLight.color;
                return float4((ambientLight + diffuseLight + specularLight * 10 /* <-- vaihtoehtoinen 10 */) * color.rgb, 1);
            }
            
            float4 frag (Varyings input) : SV_TARGET
            {
                const float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv, _MainTex));
                const float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, TRANSFORM_TEX(input.uv, _MainTex)));
                const float3x3 TangentToWorld = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);

                const float3 normalWS = TransformTangentToWorld(normalTS, TangentToWorld, true);

                input.normalWS = normalWS;
                
                return BlinnPhong(input, texColor);
            }
            ENDHLSL
        }

        Pass
        {
        Name "Depth"
        Tags { "LightMode" = "DepthOnly" }
    
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask R
    
        HLSLPROGRAM
    
        #pragma vertex DepthVert
        #pragma fragment DepthFrag

        // PITÄÄ OLLA RELATIVE PATH TIEDOSTOON!!!
        #include "../Common/DepthOnly.hlsl"

        ENDHLSL

        }
        
        Pass
        {
        Name "Normals"
        Tags { "LightMode" = "DepthNormalsOnly" }
    
        Cull Back
        ZTest LEqual
        ZWrite On
    
        HLSLPROGRAM
    
        #pragma vertex DepthNormalsVert
        #pragma fragment DepthNormalsFrag

        #include "../Common/DepthNormalsOnly.hlsl"
    
        ENDHLSL
        }
    }
}