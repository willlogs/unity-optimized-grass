using UnityEngine;
using UnityEditor;
using System.IO;

namespace GradientSkybox
{
    public class CircularMultipleColorGradientSkyboxGUI : ShaderGUI
    {
        private GradientObject gradientObject = null;
        private bool isGradientSaved = false;

        public override void OnGUI(MaterialEditor editor, MaterialProperty[] properties)
        {
            MaterialProperty norm = FindProperty("_Norm", properties);
            editor.ShaderProperty(norm, norm.displayName);

            Material material = editor.target as Material;
            string materialRelativePath = AssetDatabase.GetAssetPath(material);

            if (gradientObject == null)
            {
                string objectRelativePath = materialRelativePath + ".asset";
                gradientObject = AssetDatabase.LoadAssetAtPath<GradientObject>(objectRelativePath);
                if (gradientObject == null)
                {
                    gradientObject = ScriptableObject.CreateInstance<GradientObject>();
                    AssetDatabase.CreateAsset(gradientObject, objectRelativePath);
                    AssetDatabase.Refresh();
                }
            }

            SerializedObject data = new SerializedObject(gradientObject);
            data.Update();
            SerializedProperty gradientProperty = data.FindProperty("gradient");
            Texture2D texture = null;

            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(gradientProperty);
            if (EditorGUI.EndChangeCheck())
            {
                data.ApplyModifiedProperties();
                texture = CreateRampTexture();
                texture.wrapMode = TextureWrapMode.Clamp;
                material.SetTexture("_RampTex", texture);
                isGradientSaved = false;
            }

            if (GUILayout.Button("Save Gradient"))
            {
                if (texture == null)
                {
                    texture = CreateRampTexture();
                }

                byte[] png = texture.EncodeToPNG();
                string textureRelativePath = materialRelativePath + ".png";
                string textureAbsolutePath = Path.Combine(Directory.GetCurrentDirectory(), textureRelativePath);
                File.WriteAllBytes(textureAbsolutePath, png);

                TextureImporter textureImporter = AssetImporter.GetAtPath(textureRelativePath) as TextureImporter;
                textureImporter.wrapMode = TextureWrapMode.Clamp;
                AssetDatabase.ImportAsset(textureRelativePath);

                Texture2D savedTexture = AssetDatabase.LoadAssetAtPath<Texture2D>(textureRelativePath);
                material.SetTexture("_RampTex", savedTexture);

                isGradientSaved = true;
            }

            if (!isGradientSaved)
            {
                EditorGUILayout.HelpBox("Changes to gradient has not saved yet.", MessageType.Warning);
            }
        }


        private Texture2D CreateRampTexture()
        {
            Gradient gradient = gradientObject.gradient;
            Texture2D texture = new Texture2D(128, 2);
            for (int h = 0; h < texture.height; h++)
            {
                for (int w = 0; w < texture.width; w++)
                {
                    texture.SetPixel(w, h, gradient.Evaluate((float)w / texture.width));
                }
            }
            texture.Apply();
            return texture;
        }
    }
}
