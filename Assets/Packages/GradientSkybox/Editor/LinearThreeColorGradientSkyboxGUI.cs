using UnityEngine;
using UnityEditor;

namespace GradientSkybox
{
    public class LinearThreeColorGradientSkyboxGUI : ShaderGUI
    {
        public override void OnGUI(MaterialEditor editor, MaterialProperty[] properties)
        {
            MaterialProperty topColor = FindProperty("_TopColor", properties);
            editor.ColorProperty(topColor, topColor.displayName);
            MaterialProperty middleColor = FindProperty("_MiddleColor", properties);
            editor.ColorProperty(middleColor, middleColor.displayName);
            MaterialProperty bottomColor = FindProperty("_BottomColor", properties);
            editor.ColorProperty(bottomColor, bottomColor.displayName);
            MaterialProperty up = FindProperty("_Up", properties);
            Vector3 upVector = up.vectorValue;
            upVector = EditorGUILayout.Vector3Field(up.displayName, upVector);
            up.vectorValue = upVector;
            MaterialProperty exp = FindProperty("_Exp", properties);
            editor.RangeProperty(exp, exp.displayName);
        }
    }
}